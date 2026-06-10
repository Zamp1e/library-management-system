package com.library.config;

import com.library.entity.User;
import com.library.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

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
