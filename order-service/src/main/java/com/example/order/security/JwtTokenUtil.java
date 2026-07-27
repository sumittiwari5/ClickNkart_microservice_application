package com.example.order.security;

import java.util.List;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

/** Same shared-secret validation pattern as catalog-service - see that copy's comments for why. */
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

	public int getUserId(String token) {
		return Integer.parseInt(claims(token).getSubject().split(",")[0]);
	}

	public List<String> getRoles(String token) {
		String subject = claims(token).getSubject();
		String[] parts = subject.split(",", 4);
		String rolesRaw = parts[3].replaceAll("[\\[\\]]", "");
		return List.of(rolesRaw.split(",\\s*"));
	}

	private Claims claims(String token) {
		return Jwts.parser().setSigningKey(key()).build().parseClaimsJws(token).getBody();
	}
}
