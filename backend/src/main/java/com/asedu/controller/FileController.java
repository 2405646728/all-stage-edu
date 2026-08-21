package com.asedu.controller;

import com.asedu.base.entity.BaseFile;
import com.asedu.base.mapper.BaseFileMapper;
import com.asedu.common.api.R;
import com.asedu.security.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.UUID;

/** 统一文件上传/下载（对应 db 表 base_file） */
@RestController
@RequestMapping("/api/file")
@RequiredArgsConstructor
public class FileController {

    private final BaseFileMapper fileMapper;

    @Value("${asedu.file.upload-dir:./uploads}")
    private String uploadDir;

    @PostMapping("/upload")
    public R<BaseFile> upload(@RequestParam("file") MultipartFile file,
                              @RequestParam(defaultValue = "general") String bizType,
                              @RequestParam(required = false) Long bizId) throws IOException {
        if (file.isEmpty()) {
            throw new com.asedu.common.exception.BusinessException("文件不能为空");
        }
        Path dir = Paths.get(uploadDir).toAbsolutePath().normalize();
        Files.createDirectories(dir);
        String ext = "";
        String name = file.getOriginalFilename();
        if (name != null && name.contains(".")) {
            ext = name.substring(name.lastIndexOf('.'));
        }
        String stored = LocalDate.now().toString() + "/" + UUID.randomUUID().toString().replace("-", "") + ext;
        Path target = dir.resolve(stored);
        Files.createDirectories(target.getParent());
        Files.copy(file.getInputStream(), target);

        BaseFile bf = new BaseFile();
        bf.setOrgId(UserContext.orgId() == null ? 0L : UserContext.orgId());
        bf.setBizType(bizType);
        bf.setBizId(bizId == null ? 0L : bizId);
        bf.setFileName(name == null ? "unnamed" : name);
        bf.setFilePath(stored);
        bf.setFileSize(file.getSize());
        bf.setMimeType(file.getContentType() == null ? "" : file.getContentType());
        bf.setUploaderId(UserContext.userId());
        fileMapper.insert(bf);
        return R.ok(bf);
    }

    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> download(@PathVariable Long id) throws IOException {
        BaseFile bf = fileMapper.selectById(id);
        if (bf == null) {
            return ResponseEntity.notFound().build();
        }
        Path file = Paths.get(uploadDir).toAbsolutePath().normalize().resolve(bf.getFilePath());
        Resource resource = new UrlResource(file.toUri());
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }
        String encoded = java.net.URLEncoder.encode(bf.getFileName(), "UTF-8");
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + encoded + "\"")
                .body(resource);
    }
}
