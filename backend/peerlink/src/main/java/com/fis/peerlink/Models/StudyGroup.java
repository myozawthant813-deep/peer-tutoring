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
    import jakarta.persistence.OneToMany;
    import jakarta.persistence.Table;

    @Entity 
    @Table (name = "study_groups")

    public class StudyGroup {

        @Id
        @GeneratedValue (strategy = GenerationType.IDENTITY)
        private Long id;


        public long getId() {
            return id;
        }


        @Column (nullable = false, length = 100)
        private String name;

        @Column (nullable = false, length = 100)
        private String subject;

        @Column (length = 1000)
        private String description;


        @ManyToOne  (fetch = FetchType.LAZY)
        @JoinColumn (name = "creator_id", nullable = false)
        private User creator;

        @Column (name = "created_at", nullable = false)
        private LocalDateTime createdAt = LocalDateTime.now();

        public StudyGroup() {
        
        }


        


        public StudyGroup(String name, String subject, String description, User creator) {
            this.name = name;
            this.subject = subject;
            this.description = description;
            this.creator = creator;
            this.createdAt = createdAt;
        }


        public String getName() {
            return name;
        }


        public void setName(String name) {
            this.name = name;
        }


        public String getSubject() {
            return subject;
        }


        public void setSubject(String subject) {
            this.subject = subject;
        }


        public String getDescription() {
            return description;
        }


        public void setDescription(String description) {
            this.description = description;
        }


        public User getCreator() {
            return creator;
        }


        public void setCreator(User creator) {
            this.creator = creator;
        }


        public LocalDateTime getCreatedAt() {
            return createdAt;
        }


        public void setCreatedAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
        }

        
    }