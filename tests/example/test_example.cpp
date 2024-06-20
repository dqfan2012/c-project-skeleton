#include <gtest/gtest.h>

extern "C" {
    bool function_to_test();
}

TEST(ExampleTest, TestFunction) {
    EXPECT_TRUE(function_to_test());
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
