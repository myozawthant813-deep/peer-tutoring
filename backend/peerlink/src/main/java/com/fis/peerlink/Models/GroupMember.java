package com.fis.peerlink.Models;

import java.time.LocalDateTime;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity 
@Table (name = "group_members", uniqueConstraints = @UniqueConstraint (columnNames = {"group_id", "user_id"}))
public class GroupMember {

    @Id 
    @GeneratedValue (strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne (fetch = FetchType.LAZY)
    @JoinColumn (name = "group_id", nullable = false)
    private StudyGroup studyGroup;

    @ManyToOne (fetch = FetchType.LAZY)
    @JoinColumn (name = "user_id", nullable = false)
    private User user;


    @Column (name = "joined_at", nullable = false)
    private LocalDateTime joinedAt = LocalDateTime.now();


    public GroupMember() {
    }


    public GroupMember(StudyGroup studyGroup, User user) {
        this.studyGroup = studyGroup;
        this.user = user;
        this.joinedAt = joinedAt;
    }


    public Long getId() {
        return id;
    }

   
    public StudyGroup getStudyGroup() {
        return studyGroup;
    }


    public void setStudyGroup(StudyGroup studyGroup) {
        this.studyGroup = studyGroup;
    }


    public User getUser() {
        return user;
    }


    public void setUser(User user) {
        this.user = user;
    }


    public LocalDateTime getJoinedAt() {
        return joinedAt;
    }


    public void setJoinedAt(LocalDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }
    


    
}
