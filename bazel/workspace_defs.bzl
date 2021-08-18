# Copyright (c) 2009-2021, Google LLC
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Google LLC nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Google LLC BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""Repository rule for using Python 3.x headers from the system."""

_build_file = """
cc_library(
   name = "python_headers",
   hdrs = glob(["python/**/*.h"]),
   includes = ["python"],
   visibility = ["//visibility:public"],
)
"""

def _find_python_dir(repository_ctx):
  versions = ["3.6", "3.7", "3.8", "3.9", "3.10", "3.11"]
  for version in versions:
    path = "/usr/include/python" + version
    if repository_ctx.path(path + "/" + "Python.h").exists:
      return path
  fail("No Python headers found in /usr/include/python3.* (require 3.6 or newer)")

def _python_headers_impl(repository_ctx):
  path = _find_python_dir(repository_ctx)
  repository_ctx.symlink(path, "python")
  repository_ctx.file("BUILD.bazel", _build_file)

# The python_headers() repository rule exposes Python headers from the system.
#
# In WORKSPACE:
#   python_headers(
#       name = "python_headers_repo",
#   )
#
# This repository exposes a single rule that you can depend on from BUILD:
#   cc_library(
#     name = "foobar",
#     srcs = ["foobar.cc"],
#     deps = ["@python_headers_repo//:python_headers"],
#   )
#
# The headers will be from any version of Python >=3.6.  This is intended for
# use with the Python "limited API," which only exposes symbols that are ABI
# compatible from version to version.
python_headers = repository_rule(
    implementation = _python_headers_impl,
    local = True,
)
