package com.fis.peerlink.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fis.peerlink.Models.StudyGroup;
import java.util.List;


public interface StudyGroupsRepository extends JpaRepository<StudyGroup, Long>{

    List<StudyGroup> findBySubjectContainingIgnoreCase(String subject);


    List<StudyGroup> findByCreator_Id(long creatorId);

    
} 
