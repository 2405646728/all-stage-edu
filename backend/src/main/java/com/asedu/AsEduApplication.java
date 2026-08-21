package com.asedu;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

/**
 * 全学段一站式学生综合管理系统（幼儿园-大学全覆盖）启动类
 * 技术栈：Spring Boot 3.3 + JDK 21 + MySQL 8.0.45 + Redis 5.0.14.1
 */
@SpringBootApplication
@MapperScan("com.asedu.**.mapper")
@ConfigurationPropertiesScan
public class AsEduApplication {

    public static void main(String[] args) {
        SpringApplication.run(AsEduApplication.class, args);
    }
}
