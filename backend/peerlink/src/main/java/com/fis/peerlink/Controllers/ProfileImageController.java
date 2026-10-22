package com.fis.peerlink.Controllers;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.UUID;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.fis.peerlink.Models.User;
import com.fis.peerlink.Repositories.UserRepository;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class ProfileImageController {

    private final UserRepository userRepository;

    private final Path uploadDirectory =
            Paths.get("uploads", "profile-images")
                    .toAbsolutePath()
                    .normalize();

    public ProfileImageController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping(
        value = "/{id}/profile-image",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public Map<String, Object> uploadProfileImage(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file) {

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "User not found"));

        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Please select an image");
        }

        String contentType = file.getContentType();

        if (contentType == null ||
                !(contentType.equals("image/jpeg")
                || contentType.equals("image/png")
                || contentType.equals("image/webp"))) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Only JPG, PNG, and WEBP images are allowed");
        }

        if (file.getSize() > 5 * 1024 * 1024) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Image must be 5 MB or smaller");
        }

        try {
            Files.createDirectories(uploadDirectory);

            String extension;

            if (contentType.equals("image/png")) {
                extension = ".png";
            } else if (contentType.equals("image/webp")) {
                extension = ".webp";
            } else {
                extension = ".jpg";
            }

            String filename = UUID.randomUUID() + extension;

            Path destination = uploadDirectory
                    .resolve(filename)
                    .normalize();

            if (!destination.startsWith(uploadDirectory)) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Invalid filename");
            }

            Files.copy(
                    file.getInputStream(),
                    destination,
                    StandardCopyOption.REPLACE_EXISTING);

            String imageUrl =
                    "/uploads/profile-images/" + filename;

            user.setProfileImage(imageUrl);
            userRepository.save(user);

            return Map.of(
                    "message", "Profile image uploaded successfully",
                    "profileImage", imageUrl
            );

        } catch (IOException e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Failed to save profile image");
        }
    }

    // Public endpoint for viewing profile images.
    @GetMapping(
        value = "/uploads/profile-images/{filename:.+}",
        produces = MediaType.APPLICATION_OCTET_STREAM_VALUE
    )
    public ResponseEntity<Resource> getProfileImage(
            @PathVariable String filename) {

        // UUID filenames prevent arbitrary path traversal.
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

            MediaType mediaType;

            if (contentType != null
                    && contentType.equals("image/png")) {
                mediaType = MediaType.IMAGE_PNG;
            } else if (contentType != null
                    && contentType.equals("image/webp")) {
                mediaType = MediaType.parseMediaType("image/webp");
            } else {
                mediaType = MediaType.IMAGE_JPEG;
            }

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

