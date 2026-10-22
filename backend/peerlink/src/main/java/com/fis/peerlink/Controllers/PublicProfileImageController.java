package com.fis.peerlink.Controllers;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class PublicProfileImageController {

    private final Path uploadDirectory =
            Paths.get("uploads", "profile-images")
                    .toAbsolutePath()
                    .normalize();

    @GetMapping("/uploads/profile-images/{filename:.+}")
    public ResponseEntity<Resource> getProfileImage(
            @PathVariable String filename) {

        if (!filename.matches(
                "^[0-9a-fA-F-]{36}\\.(jpg|png|webp)$")) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid image filename");
        }

        try {
            Path imagePath = uploadDirectory
                    .resolve(filename)
                    .normalize();

            if (!imagePath.startsWith(uploadDirectory)
                    || !Files.isRegularFile(imagePath)) {
                throw new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Image not found");
            }

            Resource resource = new UrlResource(imagePath.toUri());

            String contentType = Files.probeContentType(imagePath);

            MediaType mediaType = contentType == null
                    ? MediaType.APPLICATION_OCTET_STREAM
                    : MediaType.parseMediaType(contentType);

            return ResponseEntity.ok()
                    .contentType(mediaType)
                    .body(resource);

        } catch (IOException e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Failed to read profile image");
        }
    }
}
