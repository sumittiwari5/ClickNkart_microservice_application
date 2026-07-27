package com.example.user.services;

import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.example.user.models.User;
import com.example.user.models.UserDto;
import com.example.user.repositories.UserRepository;

@Service
public class UserService {

	@Autowired
	private UserRepository repository;

	@Autowired
	private PasswordEncoder encoder;

	public User registeruser(UserDto dto) {
		if (repository.existsByUsername(dto.getUsername())) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username already exists");
		}
		if (repository.existsByEmail(dto.getEmail())) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists");
		}
		User user = new User();
		user.setEmail(dto.getEmail());
		user.setUsername(dto.getUsername());
		user.setMobile(dto.getMobile());
		user.setRoles(dto.getRoles() == null ? Arrays.asList("ROLE_USER") : dto.getRoles());
		user.setPassword(encoder.encode(dto.getPassword()));
		return repository.save(user);
	}
}
