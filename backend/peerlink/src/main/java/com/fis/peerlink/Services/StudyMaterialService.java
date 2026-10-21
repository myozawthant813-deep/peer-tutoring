package com.fis.peerlink.Services;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.fis.peerlink.Models.StudyMaterial;
import com.fis.peerlink.Models.User;
import com.fis.peerlink.Repositories.StudyMaterialRepository;
import com.fis.peerlink.Repositories.UserRepository;

@Service
public class StudyMaterialService {

    private final StudyMaterialRepository materialRepository;
    private final UserRepository userRepository;

    public StudyMaterialService(
            StudyMaterialRepository materialRepository,
            UserRepository userRepository) {
        this.materialRepository = materialRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Map<String, Object> createMaterial(
            String title,
            String description,
            String subject,
            String fileUrl,
            Long userId) {

        if (title == null || title.isBlank()
                || subject == null || subject.isBlank()
                || fileUrl == null || fileUrl.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Title, subject, and file URL are required.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "User not found."));

        StudyMaterial material = new StudyMaterial(
                title.trim(),
                description == null ? "" : description.trim(),
                subject.trim(),
                fileUrl.trim(),
                user);

        return toMap(materialRepository.save(material));
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllMaterials() {
        return materialRepository.findAll()
                .stream()
                .map(this::toMap)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> searchMaterials(String subject) {
        if (subject == null || subject.isBlank()) {
            return getAllMaterials();
        }

        return materialRepository
                .findBySubjectContainingIgnoreCase(subject.trim())
                .stream()
                .map(this::toMap)
                .toList();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getMaterialById(Long id) {
        StudyMaterial material = materialRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Study material not found."));

        return toMap(material);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMaterialsByUser(Long userId) {
        return materialRepository.findByUploadedBy_Id(userId)
                .stream()
                .map(this::toMap)
                .toList();
    }

    private Map<String, Object> toMap(StudyMaterial material) {
        Map<String, Object> result = new java.util.LinkedHashMap<>();

        result.put("id", material.getId());
        result.put("title", material.getTitle());
        result.put("description", material.getDescription());
        result.put("subject", material.getSubject());
        result.put("fileUrl", material.getFileUrl());
        result.put("uploadedById", material.getUploadedBy().getId());
        result.put("uploadedByName", material.getUploadedBy().getName());
        result.put("createdAt", material.getCreatedAt());

        return result;
    }
    @Transactional
    public void deleteMaterial(Long materialId, Long userId) {

        StudyMaterial material = materialRepository.findById(materialId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Study material not found."));

        User uploader = material.getUploadedBy();

        if (uploader == null
                || !String.valueOf(uploader.getId())
                        .equals(String.valueOf(userId))) {

            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You can only delete your own study materials.");
        }

        materialRepository.delete(material);
    }

    @Transactional
    public Map<String, Object> updateMaterial(
            Long materialId,
            Long userId,
            String title,
            String description,
            String subject,
            String fileUrl) {

        StudyMaterial material = materialRepository.findById(materialId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Study material not found."));

        User uploader = material.getUploadedBy();

        if (uploader == null
                || !String.valueOf(uploader.getId())
                        .equals(String.valueOf(userId))) {

            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You can only edit your own study materials.");
        }

        if (title == null || title.isBlank()
                || subject == null || subject.isBlank()
                || fileUrl == null || fileUrl.isBlank()) {

            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Title, subject, and file URL are required.");
        }

        material.setTitle(title.trim());
        material.setDescription(
                description == null ? "" : description.trim());
        material.setSubject(subject.trim());
        material.setFileUrl(fileUrl.trim());

        StudyMaterial updatedMaterial = materialRepository.save(material);

        return toMap(updatedMaterial);
    }


}
