package com.fis.peerlink.Repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fis.peerlink.Models.GroupMember;
import java.util.List;


public interface GroupMemberRepository extends JpaRepository<GroupMember, Long>{


    boolean existsByStudyGroup_IdAndUser_Id(
        Long groupId,
        Long userId
    );


    Optional<GroupMember> findByStudyGroup_IdAndUser_Id(
        Long groupId,
        Long userId
    );


    List<GroupMember> findByStudyGroup_Id(Long groupId);
    List<GroupMember> findByUser_Id(Long userId);


    long countByStudyGroup_Id(Long groupId);
    
}
