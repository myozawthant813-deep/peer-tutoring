package com.fis.peerlink.Services;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.fis.peerlink.Models.GroupMember;
import com.fis.peerlink.Models.StudyGroup;
import com.fis.peerlink.Models.StudyMaterial;
import com.fis.peerlink.Models.User;
import com.fis.peerlink.Repositories.GroupMemberRepository;
import com.fis.peerlink.Repositories.StudyGroupsRepository;
import com.fis.peerlink.Repositories.UserRepository;

@Service
public class StudyGroupService {

    private final StudyGroupsRepository studyGroupsRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;

    public StudyGroupService(
            StudyGroupsRepository studyGroupsRepository,
            GroupMemberRepository groupMemberRepository,
            UserRepository userRepository) {

        this.studyGroupsRepository = studyGroupsRepository;
        this.groupMemberRepository = groupMemberRepository;
        this.userRepository = userRepository;
    }

    // Create a study group and automatically add its creator
    @Transactional
    public Map<String, Object> createGroup(
            String name,
            String subject,
            String description,
            Long creatorId) {

        if (name == null || name.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Group name is required");
        }

        if (subject == null || subject.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Subject is required");
        }

        User creator = userRepository.findById(creatorId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Creator not found"));

        StudyGroup group = new StudyGroup(
                name.trim(),
                subject.trim(),
                description == null ? "" : description.trim(),
                creator);

        StudyGroup savedGroup = studyGroupsRepository.save(group);

        GroupMember membership = new GroupMember(savedGroup, creator);
        groupMemberRepository.save(membership);

        return groupToMap(savedGroup);
    }

    // Get all study groups
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllGroups() {

        return studyGroupsRepository.findAll()
                .stream()
                .map(this::groupToMap)
                .toList();
    }

    // Search groups by subject
    @Transactional(readOnly = true)
    public List<Map<String, Object>> searchGroups(String subject) {

        if (subject == null || subject.isBlank()) {
            return getAllGroups();
        }

        return studyGroupsRepository
                .findBySubjectContainingIgnoreCase(subject.trim())
                .stream()
                .map(this::groupToMap)
                .toList();
    }

    // Get one study group's details
    @Transactional(readOnly = true)
    public Map<String, Object> getGroupById(Long groupId) {

        StudyGroup group = studyGroupsRepository.findById(groupId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Study group not found"));

        return groupToMap(group);
    }

    @Transactional
    public Map<String, Object> joinGroup(Long groupId, Long userId) {

        StudyGroup group = studyGroupsRepository.findById(groupId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Study group not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "User not found"));

        if (groupMemberRepository
                .existsByStudyGroup_IdAndUser_Id(groupId, userId)) {

            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You have already joined this group");
        }

        GroupMember membership = new GroupMember(group, user);
        groupMemberRepository.save(membership);

        return Map.of(
                "message", "Successfully joined the study group",
                "groupId", groupId,
                "userId", userId);
    }

    // Leave a study group
    @Transactional
    public Map<String, Object> leaveGroup(Long groupId, Long userId) {

        GroupMember membership = groupMemberRepository
                .findByStudyGroup_IdAndUser_Id(groupId, userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Membership not found"));

        groupMemberRepository.delete(membership);

        return Map.of(
                "message", "Successfully left the study group",
                "groupId", groupId,
                "userId", userId);
    }

    // Get all members of a study group
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getGroupMembers(Long groupId) {

        if (!studyGroupsRepository.existsById(groupId)) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Study group not found");
        }

        return groupMemberRepository.findByStudyGroup_Id(groupId)
                .stream()
                .map(this::memberToMap)
                .toList();
    }

    // Convert a study group into a JSON-friendly response
    private Map<String, Object> groupToMap(StudyGroup group) {

        Map<String, Object> result = new LinkedHashMap<>();

        result.put("id", group.getId());
        result.put("name", group.getName());
        result.put("subject", group.getSubject());
        result.put("description", group.getDescription());
        result.put("creatorId", group.getCreator().getId());
        result.put("creatorName", group.getCreator().getName());
        result.put("createdAt", group.getCreatedAt());

        result.put(
                "memberCount",
                groupMemberRepository.countByStudyGroup_Id(group.getId()));

        return result;
    }

    // Convert a membership into a JSON-friendly response
    private Map<String, Object> memberToMap(GroupMember member) {

        Map<String, Object> result = new LinkedHashMap<>();

        result.put("id", member.getUser().getId());
        result.put("name", member.getUser().getName());
        result.put("email", member.getUser().getEmail());
        result.put("joinedAt", member.getJoinedAt());

        return result;
    };


}
