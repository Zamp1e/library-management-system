package com.library.config;

import com.library.entity.User;
import com.library.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 数据初始化器（应用启动时自动执行）
 *
 * 扫描用户表中密码长度 < 20 的记录（初始明文密码），
 * 用 BCrypt 加密后更新。确保种子数据中的明文密码在首次启动后变为密文。
 * 实现 CommandLineRunner 接口，在 Spring Boot 启动完成后自动调用。
 */
@Component
public class DataInitializer implements CommandLineRunner {
    private final UserRepository userRepo;
    private final PasswordEncoder encoder;

    public DataInitializer(UserRepository userRepo, PasswordEncoder encoder) {
        this.userRepo = userRepo;
        this.encoder = encoder;
    }

    @Override
    public void run(String... args) {
        // 首次启动时自动加密所有明文密码
        for (User u : userRepo.findAll()) {
            if (u.getPassword().length() < 20) { // 短密码 = 未加密
                u.setPassword(encoder.encode(u.getPassword()));
                userRepo.save(u);
                System.out.println("[Init] 密码已加密: " + u.getUsername());
            }
        }
    }
}
