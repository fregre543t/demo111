package models

import "errors"

var (
	ErrUserNotFound    = errors.New("用户不存在")
	ErrUserExists      = errors.New("用户名已存在")
	ErrInvalidPassword = errors.New("密码错误")
	ErrMessageNotFound = errors.New("消息不存在")
)
