package com.fis.peerlink.Controllers;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import com.fis.peerlink.Services.StudyGroupService;

@RestController
@RequestMapping("/api/study-groups")
@CrossOrigin(origins = "*")
public class StudyGroupController {

    private final StudyGroupService studyGroupService;

    public StudyGroupController(StudyGroupService studyGroupService) {
        this.studyGroupService = studyGroupService;
    }

    // Create a study group
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> createGroup(
            @RequestBody Map<String, Object> request) {

        String name = (String) request.get("name");
        String subject = (String) request.get("subject");
        String description = (String) request.get("description");
        Long creatorId = Long.valueOf(
                request.get("creatorId").toString());

        return studyGroupService.createGroup(
                name, subject, description, creatorId);
    }

    // Get all study groups or search by subject
    @GetMapping
    public List<Map<String, Object>> getGroups(
            @RequestParam(required = false) String subject) {

        if (subject != null && !subject.isBlank()) {
            return studyGroupService.searchGroups(subject);
        }

        return studyGroupService.getAllGroups();
    }

    // Get details of one study group
    @GetMapping("/{groupId}")
    public Map<String, Object> getGroupById(
            @PathVariable Long groupId) {

        return studyGroupService.getGroupById(groupId);
    }

    // Join a study group
    @PostMapping("/{groupId}/join")
    public Map<String, Object> joinGroup(
            @PathVariable Long groupId,
            @RequestBody Map<String, Object> request) {

        Long userId = Long.valueOf(
                request.get("userId").toString());

        return studyGroupService.joinGroup(groupId, userId);
    }

    // Leave a study group
    @DeleteMapping("/{groupId}/leave/{userId}")
    public Map<String, Object> leaveGroup(
            @PathVariable Long groupId,
            @PathVariable Long userId) {

        return studyGroupService.leaveGroup(groupId, userId);
    }

    // Get members of a study group
    @GetMapping("/{groupId}/members")
    public List<Map<String, Object>> getGroupMembers(
            @PathVariable Long groupId) {

        return studyGroupService.getGroupMembers(groupId);
    }
}
