package com.library.service;

import com.library.entity.User;
import com.library.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class AuthService {
    private final UserRepository userRepo;
    private final PasswordEncoder encoder;

    public AuthService(UserRepository userRepo, PasswordEncoder encoder) {
        this.userRepo = userRepo;
        this.encoder = encoder;
    }

    public Map<String, Object> login(String username, String password) {
        User u = userRepo.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("用户名或密码错误"));
        if (u.getStatus() == 0)
            throw new RuntimeException("账号已被禁用");
        if (!encoder.matches(password, u.getPassword()))
            throw new RuntimeException("用户名或密码错误");

        String token = "token-" + u.getId() + "-" + UUID.randomUUID().toString().substring(0, 8);
        Map<String, Object> user = new HashMap<>();
        user.put("id", u.getId());
        user.put("username", u.getUsername());
        user.put("role", u.getRole());
        user.put("name", u.getName());
        user.put("phone", u.getPhone() != null ? u.getPhone() : "");

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", user);
        return result;
    }

    public Map<String, Object> me(Integer userId) {
        User u = userRepo.findById(userId)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        Map<String, Object> user = new HashMap<>();
        user.put("id", u.getId());
        user.put("username", u.getUsername());
        user.put("role", u.getRole());
        user.put("name", u.getName());
        user.put("phone", u.getPhone() != null ? u.getPhone() : "");
        return user;
    }
}
