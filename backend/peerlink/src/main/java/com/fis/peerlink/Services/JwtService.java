package com.fis.peerlink.Services;

import java.nio.charset.StandardCharsets;
import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtService {

private final SecretKey secretKey;
private final long expirationMs;

public JwtService(
        @Value("${security.jwt.secret}") String secret,
        @Value("${security.jwt.expiration-ms:3600000}") long expirationMs) {

    byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);

    this.secretKey = Keys.hmacShaKeyFor(keyBytes);
    this.expirationMs = expirationMs;
}

public String generateToken(Long userId, String email) {
    Date now = new Date();
    Date expiration = new Date(now.getTime() + expirationMs);

    return Jwts.builder()
            .subject(email)
            .claim("userId", userId)
            .issuedAt(now)
            .expiration(expiration)
            .signWith(secretKey)
            .compact();
}

public Claims extractClaims(String token) {
    return Jwts.parser()
            .verifyWith(secretKey)
            .build()
            .parseSignedClaims(token)
            .getPayload();
}

}
