package com.asedu.sys.vo;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class OrgVO {

    private Long id;
    private String orgCode;
    private String orgName;
    private String stage;
    private String schoolType;
    private String province;
    private String city;
    private String district;
    private String address;
    private String contactName;
    private String contactPhone;
    private Integer status;
    private LocalDate serviceStart;
    private LocalDate serviceEnd;
    private String auditRemark;
    private LocalDateTime createdAt;
}
