package com.fis.peerlink.Controllers;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import com.fis.peerlink.Services.StudyMaterialService;

@RestController
@RequestMapping("/api/study-materials")
@CrossOrigin(origins = "*")
public class StudyMaterialController {

    private final StudyMaterialService materialService;

    public StudyMaterialController(StudyMaterialService materialService) {
        this.materialService = materialService;
    }

    // Create a study material
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createMaterial(
            @RequestBody Map<String, Object> request) {

        return materialService.createMaterial(
                (String) request.get("title"),
                (String) request.get("description"),
                (String) request.get("subject"),
                (String) request.get("fileUrl"),
                Long.valueOf(request.get("uploadedById").toString())
        );
    }

    // Get all materials or search by subject
    @GetMapping
    public List<Map<String, Object>> getMaterials(
            @RequestParam(required = false) String subject) {

        return materialService.searchMaterials(subject);
    }

    // Get one material by ID
    @GetMapping("/{id}")
    public Map<String, Object> getMaterialById(@PathVariable Long id) {
        return materialService.getMaterialById(id);
    }

    // Get materials uploaded by a specific user
    @GetMapping("/user/{userId}")
    public List<Map<String, Object>> getMaterialsByUser(
            @PathVariable Long userId) {

        return materialService.getMaterialsByUser(userId);
    }
}
