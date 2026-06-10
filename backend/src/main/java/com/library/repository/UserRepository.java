package com.library.repository;

import com.library.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByUsername(String username);
    List<User> findByRole(String role);
    List<User> findByRoleAndNameContainingOrRoleAndUsernameContaining(
        String role1, String keyword1, String role2, String keyword2);
    boolean existsByUsername(String username);
}
