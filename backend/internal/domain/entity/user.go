package entity

import "time"

// User represents a user entity in the domain
type User struct {
	ID        uint
	Email     string
	Phone     string
	Password  string // Hashed password
	Name      string
	Avatar    string
	Bio       string
	Gender    string
	Birthday  *time.Time
	Height    float64
	Weight    float64
	Location  string
	
	// Social stats
	FollowersCount int
	FollowingCount int
	MatesCount     int
	PostsCount     int
	
	// Training stats
	TotalWorkouts   int
	TotalDuration   int
	TotalCalories   int
	CurrentStreak   int
	LongestStreak   int
	
	// Authentication
	Provider      string // email, phone, google, apple, wechat
	ProviderID    string
	IsEmailVerified bool
	IsPhoneVerified bool
	IsActive      bool
	
	// Timestamps
	CreatedAt time.Time
	UpdatedAt time.Time
	LastLoginAt *time.Time
}

// IsGuest returns true if the user is a guest account
func (u *User) IsGuest() bool {
	return u.Provider == "guest"
}

// CanLogin returns true if the user can login
func (u *User) CanLogin() bool {
	return u.IsActive && !u.IsGuest()
}

// UpdateProfile updates the user's profile information
func (u *User) UpdateProfile(name, avatar, bio string) {
	if name != "" {
		u.Name = name
	}
	if avatar != "" {
		u.Avatar = avatar
	}
	u.Bio = bio
	u.UpdatedAt = time.Now()
}

// UpdateStats updates user's social stats
func (u *User) UpdateStats(followers, following, mates, posts int) {
	u.FollowersCount = followers
	u.FollowingCount = following
	u.MatesCount = mates
	u.PostsCount = posts
}

