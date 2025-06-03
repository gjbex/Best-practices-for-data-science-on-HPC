#include <iostream>
#include <vector>

int main() {
    // 25'000'000 * 4 bytes = 100 MB, which should exceed the L3 cache size of most CPUs
    const int size {25'000'000};
    std::vector<int> v;
    v.reserve(size);
    for (int i = 0; i < size; ++i) {
        v[i] = sizeof(int);
    }
    int sum {0};
    for (int i = 0; i < size; ++i) {
        sum += v[i];
    }
    std::cout << sum << " bytes memory accessed" << std::endl;
    return 0;
}
