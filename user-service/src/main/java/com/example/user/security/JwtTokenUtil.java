package com.example.user.security;

import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.example.user.models.User;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

/**
 * Issues and validates JWTs.
 *
 * MICROSERVICE NOTE: this is the ONLY service that actually ISSUES tokens
 * (it owns the login endpoint). catalog-service and order-service each have
 * their own copy of the "validate a token" half of this logic, using the
 * SAME jwt.secret. That shared secret is what lets three independent Spring
 * Boot apps trust a token none of them individually created - this is the
 * simplest form of inter-service auth (a "shared trust" pattern). The next
 * level up from this, once you're comfortable, is asymmetric signing
 * (private key in user-service, public key everywhere else) or an API
 * gateway that validates tokens once at the edge.
 */
@Component
public class JwtTokenUtil {

	@Value("${jwt.secret}")
	private String jwtSecret;

	@Value("${jwt.issuer}")
	private String jwtIssuer;

	private SecretKey key() {
		return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret));
	}

	/** Called once, at login time, in user-service only. */
	public String generateToken(User user) {
		return Jwts.builder()
				.setSubject(user.getId() + "," + user.getEmail() + "," + user.getUsername() + "," + user.getRoles())
				.setIssuer(jwtIssuer)
				.setIssuedAt(new Date())
				.setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24h
				.signWith(key())
				.compact();
	}

	public String getUserId(String token) {
		return parse(token).getSubject().split(",")[0];
	}

	public String getUsername(String token) {
		return parse(token).getSubject().split(",")[2];
	}

	public String getEmail(String token) {
		return parse(token).getSubject().split(",")[1];
	}

	private Claims parse(String token) {
		return Jwts.parser().setSigningKey(key()).build().parseClaimsJws(token).getBody();
	}

	public boolean validate(String token) {
		try {
			Jwts.parser().setSigningKey(key()).build().parseClaimsJws(token);
			return true;
		} catch (MalformedJwtException e) {
			System.out.println("Invalid Jwt token - " + e.getMessage());
		} catch (ExpiredJwtException e) {
			System.out.println("Expired Jwt token - " + e.getMessage());
		} catch (UnsupportedJwtException e) {
			System.out.println("Unsupported Jwt token - " + e.getMessage());
		} catch (IllegalArgumentException e) {
			System.out.println("Jwt claims string is empty - " + e.getMessage());
		}
		return false;
	}
}
