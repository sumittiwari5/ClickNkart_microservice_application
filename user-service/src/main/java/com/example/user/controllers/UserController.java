package com.example.user.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.user.models.Token;
import com.example.user.models.User;
import com.example.user.models.UserDto;
import com.example.user.security.JwtTokenUtil;
import com.example.user.services.UserService;

import jakarta.validation.Valid;

/** Only two endpoints: register and login. Everything else about a user (their cart, orders) lives in other services now. */
@RestController
public class UserController {

	@Autowired
	private UserService service;

	@Autowired
	private JwtTokenUtil jwtTokenUtil;

	@Autowired
	private AuthenticationManager authenticationManager;

	@PostMapping("/api/register")
	public ResponseEntity<?> registerUser(@RequestBody @Valid UserDto dto) {
		User dbUser = service.registeruser(dto);
		return new ResponseEntity<>(dbUser, HttpStatus.CREATED);
	}

	@PostMapping("/api/login")
	public ResponseEntity<?> authenticateUser(@RequestBody User user) {
		try {
			Authentication authentication = authenticationManager.authenticate(
					new UsernamePasswordAuthenticationToken(user.getEmail(), user.getPassword()));

			SecurityContextHolder.getContext().setAuthentication(authentication);
			User authUser = (User) authentication.getPrincipal();

			Token t = new Token();
			t.jwtToken = jwtTokenUtil.generateToken(authUser);
			return new ResponseEntity<>(t, HttpStatus.OK);
		} catch (BadCredentialsException e) {
			return new ResponseEntity<>("Error logging in !!", HttpStatus.UNAUTHORIZED);
		}
	}
}
