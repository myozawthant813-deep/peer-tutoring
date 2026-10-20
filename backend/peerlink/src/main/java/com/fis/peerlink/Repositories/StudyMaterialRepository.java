package com.fis.peerlink.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fis.peerlink.Models.StudyMaterial;

public interface StudyMaterialRepository
        extends JpaRepository<StudyMaterial, Long> {

    List<StudyMaterial> findBySubjectContainingIgnoreCase(String subject);

    List<StudyMaterial> findByUploadedBy_Id(Long userId);
}
