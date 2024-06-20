#include <check.h>
#include <stdbool.h>
#include <stdlib.h>  // Include this header for EXIT_SUCCESS and EXIT_FAILURE

START_TEST(test_true_is_true)
{
    ck_assert(true);
}
END_TEST

Suite *example_suite(void)
{
    Suite *s;
    TCase *tc_core;

    s = suite_create("Example");
    tc_core = tcase_create("Core");

    tcase_add_test(tc_core, test_true_is_true);
    suite_add_tcase(s, tc_core);

    return s;
}

int main(void)
{
    int number_failed;
    Suite *s;
    SRunner *sr;

    s = example_suite();
    sr = srunner_create(s);

    srunner_run_all(sr, CK_NORMAL);
    number_failed = srunner_ntests_failed(sr);
    srunner_free(sr);

    return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
