package api_responses

type ResponseWrapper[T any] struct{}

type HttpResponse[T any] struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    *T     `json:"data,omitempty"`
}

func (wrapper *ResponseWrapper[T]) SuccessResponse(message string, data *T) *HttpResponse[T] {
	return &HttpResponse[T]{
		Success: true,
		Message: message,
		Data:    data,
	}
}

func (wrapper *ResponseWrapper[T]) ErrorResponse(message string) *HttpResponse[T] {
	return &HttpResponse[T]{
		Success: false,
		Message: message,
	}
}
