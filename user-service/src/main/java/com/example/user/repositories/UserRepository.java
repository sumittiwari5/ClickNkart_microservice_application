package com.example.user.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RestResource;

import com.example.user.models.User;

/**
 * Spring Data REST auto-exposes CRUD endpoints for this at /api/users.
 * We keep save() unexported (exported = false) so nobody can bypass
 * UserService's password-encoding + uniqueness checks by POSTing to
 * /api/users directly.
 */
public interface UserRepository extends JpaRepository<User, Integer> {
	@RestResource(exported = false)
	User save(User user);

	boolean existsByEmail(String email);
	boolean existsByUsername(String username);
	Optional<User> findByEmail(String email);
}
