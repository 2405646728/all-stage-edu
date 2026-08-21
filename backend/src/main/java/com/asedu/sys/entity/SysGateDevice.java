package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 门禁硬件设备全局注册表 —— 对应 db 表 sys_gate_device */
@Data
@TableName("sys_gate_device")
public class SysGateDevice implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String deviceCode;
    private String deviceName;
    private String deviceType;
    private String model;
    private String vendor;
    private String location;
    private String ip;
    private Integer port;
    private Integer status;
    private LocalDateTime lastOnlineAt;
    private String paramJson;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    @TableLogic
    private Integer isDeleted;
}