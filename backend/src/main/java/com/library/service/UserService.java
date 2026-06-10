package com.library.service;

import com.library.entity.User;
import com.library.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.*;

@Service
public class UserService {
    private final UserRepository userRepo;
    private final PasswordEncoder encoder;

    public UserService(UserRepository userRepo, PasswordEncoder encoder) {
        this.userRepo = userRepo;
        this.encoder = encoder;
    }

    private Map<String, Object> toMap(User u) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", u.getId());
        m.put("username", u.getUsername());
        m.put("role", u.getRole());
        m.put("name", u.getName());
        m.put("phone", u.getPhone() != null ? u.getPhone() : "");
        m.put("status", u.getStatus());
        m.put("createdAt", u.getCreatedAt().toString());
        return m;
    }

    public Map<String, Object> list(String role, String keyword) {
        List<User> list;
        if (role != null && keyword != null && !keyword.isEmpty()) {
            list = userRepo.findByRoleAndNameContainingOrRoleAndUsernameContaining(role, keyword, role, keyword);
        } else if (role != null) {
            list = userRepo.findByRole(role);
        } else if (keyword != null && !keyword.isEmpty()) {
            list = userRepo.findByRoleAndNameContainingOrRoleAndUsernameContaining(
                "reader", keyword, "admin", keyword);
        } else {
            list = userRepo.findAll();
        }
        Map<String, Object> result = new HashMap<>();
        result.put("list", list.stream().map(this::toMap).toList());
        result.put("total", list.size());
        return result;
    }

    public User create(User data) {
        if (userRepo.existsByUsername(data.getUsername()))
            throw new RuntimeException("用户名已存在");
        if ("super_admin".equals(data.getRole()))
            throw new RuntimeException("不允许创建系统管理员");
        User u = new User();
        u.setUsername(data.getUsername());
        u.setPassword(encoder.encode(data.getPassword() != null ? data.getPassword() : "123456"));
        u.setRole(data.getRole() != null ? data.getRole() : "reader");
        u.setName(data.getName());
        u.setPhone(data.getPhone());
        u.setStatus(1);
        u.setCreatedAt(LocalDate.now());
        return userRepo.save(u);
    }

    public User update(Integer id, User data) {
        User u = userRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        if ("super_admin".equals(data.getRole()) && !"super_admin".equals(u.getRole()))
            throw new RuntimeException("不允许升级为系统管理员");
        if (data.getUsername() != null) u.setUsername(data.getUsername());
        if (data.getPassword() != null && !data.getPassword().isEmpty())
            u.setPassword(encoder.encode(data.getPassword()));
        if (data.getName() != null) u.setName(data.getName());
        if (data.getPhone() != null) u.setPhone(data.getPhone());
        if (data.getStatus() != null) u.setStatus(data.getStatus());
        return userRepo.save(u);
    }

    public void delete(Integer id) {
        User u = userRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        if ("super_admin".equals(u.getRole()))
            throw new RuntimeException("不能删除系统管理员");
        userRepo.deleteById(id);
    }
}
