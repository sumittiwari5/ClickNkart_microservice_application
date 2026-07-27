package com.example.catalog.security;

import java.util.List;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

/**
 * catalog-service does NOT own a users table, so unlike user-service it
 * never loads a UserDetails object from a database. It only needs to know:
 * (a) is this token valid, and (b) what roles does it carry. Both come
 * straight out of the token claims, using the SAME jwt.secret user-service
 * signed it with. This is intentionally lighter-weight than user-service's
 * copy of this class - a good example of services only needing exactly what
 * they need, no more.
 */
@Component
public class JwtTokenUtil {

	@Value("${jwt.secret}")
	private String jwtSecret;

	private SecretKey key() {
		return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret));
	}

	public boolean validate(String token) {
		try {
			Jwts.parser().setSigningKey(key()).build().parseClaimsJws(token);
			return true;
		} catch (JwtException | IllegalArgumentException e) {
			return false;
		}
	}

	public String getUsername(String token) {
		return claims(token).getSubject().split(",")[2];
	}

	public List<String> getRoles(String token) {
		String subject = claims(token).getSubject();
		String[] parts = subject.split(",", 4);
		// roles were serialized as a Java List's toString(), e.g. "[ROLE_USER]"
		String rolesRaw = parts[3].replaceAll("[\\[\\]]", "");
		return List.of(rolesRaw.split(",\\s*"));
	}

	private Claims claims(String token) {
		return Jwts.parser().setSigningKey(key()).build().parseClaimsJws(token).getBody();
	}
}
