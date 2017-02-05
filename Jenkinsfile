parallel opencl: {
    node ('rocmtest') {
        stage('OCL Checkout') {
            env.CXXFLAGS = "-Werror"
            env.CTEST_PARALLEL_LEVEL = "32"
            checkout scm
        }
        withDockerContainer(image: 'rocm-opencl:1.4', args: '--device=/dev/kfd') {
            timeout(time: 1, unit: 'HOURS') {
                stage('Clang Tidy') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='clang++-3.8' cmake -DBUILD_DEV=On .. 
                        make tidy 2>&1 | tee tidy_out
                        ! grep -q "warning:" tidy_out
                    '''
                }
                stage('Clang Debug') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='clang++-3.8' cmake -DBUILD_DEV=On -DCMAKE_BUILD_TYPE=debug .. 
                        make -j32 check
                    '''
                }
                stage('Clang Release') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='clang++-3.8' cmake -DBUILD_DEV=On -DMLOPEN_TEST_ALL=On -DCMAKE_BUILD_TYPE=release .. 
                        make -j32 check
                    '''
                }
                stage('GCC Debug') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='g++-4.8' cmake -DBUILD_DEV=On -DCMAKE_BUILD_TYPE=debug .. 
                        make -j32 check
                    '''
                }
                stage('GCC Release') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='g++-4.8' cmake -DBUILD_DEV=On -DMLOPEN_TEST_ALL=On -DCMAKE_BUILD_TYPE=release .. 
                        make -j32 check
                    '''
                }
            }
        }
    }
}, hip: {
    node ('rocmtest') {
        stage('HIP Checkout') {
            env.CXXFLAGS = "-Werror"
            env.CTEST_PARALLEL_LEVEL = "32"
            checkout scm
        }
        withDockerContainer(image: 'aoc2:latest', args: '--device=/dev/kfd') {
            timeout(time: 1, unit: 'HOURS') {
                stage('Hip Debug') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='hcc' cmake -DBUILD_DEV=On -DCMAKE_BUILD_TYPE=debug .. 
                        make -j32 check
                    '''
                }
                stage('Hip Release') {
                    sh '''
                        #!/usr/bin/dumb-init /bin/bash
                        rm -rf build
                        mkdir build
                        cd build
                        CXX='hcc' cmake -DBUILD_DEV=On -DMLOPEN_TEST_ALL=On -DCMAKE_BUILD_TYPE=release .. 
                        make -j32 check
                    '''
                }
            }
        }
    }
}
