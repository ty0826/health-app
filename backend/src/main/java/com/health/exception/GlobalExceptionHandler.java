package com.health.exception;

import com.health.vo.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import javax.validation.ConstraintViolationException;
import java.time.format.DateTimeParseException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Result<Void>> handleBusinessException(BusinessException exception) {
        HttpStatus status = HttpStatus.resolve(exception.getCode());
        if (status == null) {
            status = HttpStatus.BAD_REQUEST;
        }
        return response(status, exception.getCode(), exception.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Result<Void>> handleValidationException(MethodArgumentNotValidException exception) {
        String message = exception.getBindingResult().getFieldErrors().isEmpty()
                ? "请求参数不合法"
                : exception.getBindingResult().getFieldErrors().get(0).getDefaultMessage();
        return response(HttpStatus.BAD_REQUEST, 400, message);
    }

    @ExceptionHandler(BindException.class)
    public ResponseEntity<Result<Void>> handleBindException(BindException exception) {
        String message = exception.getFieldErrors().isEmpty()
                ? "请求参数不合法"
                : exception.getFieldErrors().get(0).getDefaultMessage();
        return response(HttpStatus.BAD_REQUEST, 400, message);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<Result<Void>> handleConstraintViolation(ConstraintViolationException exception) {
        return response(HttpStatus.BAD_REQUEST, 400, exception.getMessage());
    }

    @ExceptionHandler({
            IllegalArgumentException.class,
            DateTimeParseException.class,
            MethodArgumentTypeMismatchException.class,
            HttpMessageNotReadableException.class
    })
    public ResponseEntity<Result<Void>> handleBadRequest(Exception exception) {
        String message = exception.getMessage();
        if (message == null || message.trim().isEmpty()
                || exception instanceof HttpMessageNotReadableException
                || exception instanceof MethodArgumentTypeMismatchException) {
            message = "请求参数不合法";
        }
        return response(HttpStatus.BAD_REQUEST, 400, message);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Result<Void>> handleUnexpectedException(Exception exception) {
        log.error("Unhandled request exception", exception);
        return response(HttpStatus.INTERNAL_SERVER_ERROR, 500, "系统内部错误");
    }

    private ResponseEntity<Result<Void>> response(HttpStatus status, int code, String message) {
        return ResponseEntity.status(status).body(Result.error(code, message));
    }
}
