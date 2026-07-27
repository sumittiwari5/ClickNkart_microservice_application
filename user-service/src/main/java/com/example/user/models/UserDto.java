package com.example.user.models;

import java.util.List;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Registration request payload. Unchanged from the monolith. */
public class UserDto {
	@NotNull(message = "Username is compulsory")
	private String username;
	@NotNull(message = "Email is compulsory")
	private String email;
	@NotNull(message = "Password is compulsory")
	@Pattern(regexp = "[0-9a-zA-Z@#_]*", message = "Password may contain characters: 0-9a-zA-Z@#_")
	@Size(min = 6, max = 12, message = "Password length must be 6 to 12")
	private String password;
	@NotNull(message = "mobile is compulsory")
	private String mobile;
	private List<String> roles;

	public List<String> getRoles() { return roles; }
	public void setRoles(List<String> roles) { this.roles = roles; }
	public String getUsername() { return username; }
	public void setUsername(String username) { this.username = username; }
	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }
	public String getPassword() { return password; }
	public void setPassword(String password) { this.password = password; }
	public String getMobile() { return mobile; }
	public void setMobile(String mobile) { this.mobile = mobile; }
}
