package com.example.user.models;

import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

/**
 * User entity - owned exclusively by user-service.
 *
 * MICROSERVICE NOTE: in the original monolith this class also had
 * @OneToMany relations to Cart and Orders (they lived in the same DB/JVM).
 * Those are removed here on purpose: catalog-service and order-service are
 * separate services with separate databases now, so a JPA relationship
 * across service boundaries isn't possible (and would be an anti-pattern
 * even if it were). Other services only ever know a user by the numeric
 * userId they get out of the JWT token - they never query this table.
 */
@Entity
public class User implements UserDetails {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;

	@Column(nullable = false, unique = true)
	private String username;

	@Column(nullable = false, unique = true)
	private String email;

	@Column(nullable = false)
	@JsonIgnore
	private String password;

	private String mobile;

	@ElementCollection
	private List<String> roles;

	@Transient
	private Collection<? extends GrantedAuthority> authorities;

	public User() {}

	public User(int id, String username, String email, String password, List<String> roles,
			Collection<? extends GrantedAuthority> authorities) {
		this.id = id;
		this.username = username;
		this.email = email;
		this.password = password;
		this.roles = roles;
		this.authorities = authorities;
	}

	public int getId() { return id; }
	public void setId(int id) { this.id = id; }
	public String getUsername() { return username; }
	public void setUsername(String username) { this.username = username; }
	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }
	public String getPassword() { return password; }
	public void setPassword(String password) { this.password = password; }
	public String getMobile() { return mobile; }
	public void setMobile(String mobile) { this.mobile = mobile; }
	public List<String> getRoles() { return roles; }
	public void setRoles(List<String> roles) { this.roles = roles; }

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() { return authorities; }
	@Override
	public boolean isAccountNonExpired() { return true; }
	@Override
	public boolean isAccountNonLocked() { return true; }
	@Override
	public boolean isCredentialsNonExpired() { return true; }
	@Override
	public boolean isEnabled() { return true; }
}
