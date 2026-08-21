package com.asedu.auth.service;

import com.asedu.auth.entity.AuthEmailInvite;
import com.asedu.auth.entity.AuthOpenBatch;
import com.asedu.auth.entity.AuthOpenItem;
import com.asedu.auth.entity.AuthUser;
import com.asedu.auth.mapper.AuthEmailInviteMapper;
import com.asedu.auth.mapper.AuthOpenBatchMapper;
import com.asedu.auth.mapper.AuthOpenItemMapper;
import com.asedu.auth.mapper.AuthUserMapper;
import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 账号便捷开通服务（文档 12.5 五大模式统一落账）：
 * excel批量导入 / 班级批量生成 / 台账同步 / 单条开通 / 邮箱推送一键开通
 * 规则：以学号/工号为唯一标识自动查重；初始密码统一 123456 并强制首登改密；
 *       批量操作部分成功容错（success/fail 明细）；超管可撤回。
 */
@Service
@RequiredArgsConstructor
public class AuthOpenService {

    private static final String INIT_PWD_HASH = "$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2"; // 123456

    private final AuthOpenBatchMapper batchMapper;
    private final AuthOpenItemMapper itemMapper;
    private final AuthEmailInviteMapper inviteMapper;
    private final AuthUserMapper userMapper;

    /** 创建批量开通批次并逐条开通（部分成功容错） */
    @Transactional
    public AuthOpenBatch createBatch(Long orgId, String openMode, List<Map<String, Object>> rows) {
        if (orgId == null) {
            throw new BusinessException("必须指定机构ID");
        }
        AuthOpenBatch batch = new AuthOpenBatch();
        batch.setOrgId(orgId);
        batch.setBatchNo("OB" + System.currentTimeMillis());
        batch.setOpenMode(openMode);
        batch.setTotalCount(rows == null ? 0 : rows.size());
        batch.setSuccessCount(0);
        batch.setFailCount(0);
        batch.setStatus("running");
        batch.setOperatorId(UserContext.userId());
        batchMapper.insert(batch);

        if (rows != null) {
            for (int i = 0; i < rows.size(); i++) {
                Map<String, Object> row = rows.get(i);
                AuthOpenItem item = new AuthOpenItem();
                item.setBatchId(batch.getId());
                item.setRowNo(i + 1);
                item.setUsername(String.valueOf(row.getOrDefault("username", "")));
                item.setRealName(String.valueOf(row.getOrDefault("realName", "")));
                item.setUserType(String.valueOf(row.getOrDefault("userType", "student")));
                item.setOrgId(orgId);
                item.setScopeDesc(String.valueOf(row.getOrDefault("scopeDesc", "")));
                item.setPhone(String.valueOf(row.getOrDefault("phone", "")));
                item.setEmail(String.valueOf(row.getOrDefault("email", "")));
                item.setResult("pending");
                itemMapper.insert(item);
                try {
                    createUser(item);
                    item.setResult("success");
                    item.setUserId(item.getUserId());
                    itemMapper.updateById(item);
                    batch.setSuccessCount(batch.getSuccessCount() + 1);
                } catch (Exception e) {
                    item.setResult("fail");
                    item.setFailReason(e.getMessage() == null ? "未知错误" : e.getMessage());
                    itemMapper.updateById(item);
                    batch.setFailCount(batch.getFailCount() + 1);
                }
            }
        }
        batch.setStatus(batch.getFailCount() == 0 ? "success" : "partial");
        batchMapper.updateById(batch);
        return batch;
    }

    private void createUser(AuthOpenItem item) {
        String username = item.getUsername();
        if (username == null || username.isBlank()) {
            throw new BusinessException("账号不能为空");
        }
        // 唯一查重（学号/工号唯一标识）
        Long dup = userMapper.selectCount(new LambdaQueryWrapper<AuthUser>()
                .eq(AuthUser::getUsername, username));
        if (dup != null && dup > 0) {
            throw new BusinessException("账号已存在：" + username);
        }
        AuthUser user = new AuthUser();
        user.setUsername(username);
        user.setPasswordHash(INIT_PWD_HASH);
        user.setRealName(item.getRealName());
        user.setUserType(item.getUserType());
        user.setOrgId(item.getOrgId());
        user.setPhone(item.getPhone());
        user.setEmail(item.getEmail());
        user.setStatus(1);
        user.setMustChangePwd(1);
        user.setOpenChannel(mapChannel(item.getBatchId()));
        user.setOpenBatchId(item.getBatchId());
        user.setCreatedBy(UserContext.userId());
        userMapper.insert(user);
        item.setUserId(user.getId());
    }

    private String mapChannel(Long batchId) {
        AuthOpenBatch batch = batchMapper.selectById(batchId);
        if (batch == null) {
            return "manual";
        }
        return switch (batch.getOpenMode()) {
            case "excel" -> "excel";
            case "class_batch" -> "class_batch";
            case "sync" -> "sync";
            case "email" -> "email";
            default -> "manual";
        };
    }

    public PageResult<AuthOpenBatch> pageBatch(long current, long size, Long orgId) {
        return PageResult.of(batchMapper.selectPage(new Page<>(current, size),
                new LambdaQueryWrapper<AuthOpenBatch>()
                        .eq(AuthOpenBatch::getOrgId, orgId)
                        .orderByDesc(AuthOpenBatch::getCreatedAt)));
    }

    public List<AuthOpenItem> listItems(Long batchId) {
        return itemMapper.selectList(new LambdaQueryWrapper<AuthOpenItem>()
                .eq(AuthOpenItem::getBatchId, batchId)
                .orderByAsc(AuthOpenItem::getRowNo));
    }

    /** 邮箱推送一键开通：生成邀请令牌并落账（推送动作由消息网关执行） */
    @Transactional
    public AuthEmailInvite createInvite(Long orgId, String email, String realName, String userType, String scopeDesc) {
        AuthEmailInvite invite = new AuthEmailInvite();
        invite.setOrgId(orgId);
        invite.setEmail(email);
        invite.setRealName(realName);
        invite.setUserType(userType);
        invite.setScopeDesc(scopeDesc);
        invite.setInviteToken(UUID.randomUUID().toString().replace("-", ""));
        invite.setStatus("sent");
        invite.setPushAt(LocalDateTime.now());
        invite.setCreatedBy(UserContext.userId());
        inviteMapper.insert(invite);
        return invite;
    }

    /** 用户一键确认开通（点击邮件确认按钮） */
    @Transactional
    public AuthUser confirmInvite(String token) {
        AuthEmailInvite invite = inviteMapper.selectOne(new LambdaQueryWrapper<AuthEmailInvite>()
                .eq(AuthEmailInvite::getInviteToken, token).last("LIMIT 1"));
        if (invite == null) {
            throw new BusinessException("邀请令牌无效");
        }
        if (!"sent".equals(invite.getStatus())) {
            throw new BusinessException("该邀请已处理");
        }
        AuthOpenItem item = new AuthOpenItem();
        item.setUsername(invite.getEmail());
        item.setRealName(invite.getRealName());
        item.setUserType(invite.getUserType());
        item.setOrgId(invite.getOrgId());
        item.setScopeDesc(invite.getScopeDesc());
        createUser(item);
        invite.setStatus("confirmed");
        invite.setConfirmAt(LocalDateTime.now());
        invite.setUserId(item.getUserId());
        inviteMapper.updateById(invite);
        return userMapper.selectById(item.getUserId());
    }

    public PageResult<AuthEmailInvite> pageInvites(long current, long size, Long orgId) {
        return PageResult.of(inviteMapper.selectPage(new Page<>(current, size),
                new LambdaQueryWrapper<AuthEmailInvite>()
                        .eq(AuthEmailInvite::getOrgId, orgId)
                        .orderByDesc(AuthEmailInvite::getCreatedAt)));
    }
}
