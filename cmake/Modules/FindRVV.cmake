# Check RISC-V Vector (RVV) extension availability for compile-time support.
IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
  INCLUDE(CheckCXXSourceCompiles)
  message("-- <FindRVV>")

  # The kernel code gates RVV intrinsics on v0.12 or newer
  # (__riscv_v_intrinsic >= 12000), matching the oneDNN RVV detection in
  # third_party/ideep/mkl-dnn/cmake/platform.cmake.
  SET(RVV_CODE "
    #if !defined(__riscv) || !defined(__riscv_v)
    #error \"RISC-V or vector extension (RVV) is not supported by the compiler\"
    #endif
    #if !defined(__riscv_v_intrinsic) || __riscv_v_intrinsic < 12000
    #error \"RISC-V intrinsics v0.12 or higher is required\"
    #endif
    #include <riscv_vector.h>
    int main() {
      size_t vl = __riscv_vsetvl_e32m1(4);
      float a[4] = {1.f, 2.f, 3.f, 4.f};
      float b[4] = {5.f, 6.f, 7.f, 8.f};
      float c[4] = {0.f};
      vfloat32m1_t va = __riscv_vle32_v_f32m1(a, vl);
      vfloat32m1_t vb = __riscv_vle32_v_f32m1(b, vl);
      vfloat32m1_t vc = __riscv_vfadd_vv_f32m1(va, vb, vl);
      __riscv_vse32_v_f32m1(c, vc, vl);
      return (c[0] == 6.0f) ? 0 : -1;
    }
  ")

  SET(RVV_TEST_FLAGS "-march=rv64gcv")
  SET(CMAKE_REQUIRED_FLAGS_SAVE ${CMAKE_REQUIRED_FLAGS})
  SET(CMAKE_REQUIRED_FLAGS "${RVV_TEST_FLAGS}")
  # Do compilation check instead of runtime check in case of cross-compilation.
  CHECK_CXX_SOURCE_COMPILES("${RVV_CODE}" COMPILE_OUT_RVV)
  SET(CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS_SAVE})
  if(COMPILE_OUT_RVV)
    message("-- RVV flags were set.")
    set(CXX_RVV_FOUND TRUE)
    SET(CXX_RVV_FLAGS "${RVV_TEST_FLAGS}")
  else()
    message("-- RVV flags were NOT set.")
  endif()
  message("-- </FindRVV>")
endif()
