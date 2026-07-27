package com.example.user.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.user.models.User;
import com.example.user.repositories.UserRepository;

import jakarta.transaction.Transactional;

/** Used only during login, to fetch a user by email and hand it to Spring Security for password checking. */
@Service
public class MyUserDetailsService implements UserDetailsService {

	@Autowired
	private UserRepository repository;

	@Override
	@Transactional
	public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
		User dbUser = repository.findByEmail(email)
				.orElseThrow(() -> new UsernameNotFoundException("Please login with valid email"));

		return new User(
				dbUser.getId(),
				dbUser.getUsername(),
				dbUser.getEmail(),
				dbUser.getPassword(),
				dbUser.getRoles(),
				dbUser.getRoles().stream().map(SimpleGrantedAuthority::new).toList()
		);
	}
}
