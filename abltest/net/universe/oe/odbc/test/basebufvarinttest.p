/* Testcase integer */


def var i as int no-undo.

def var iTestInts as int no-undo extent 6.

assign iTestInts[1] =  2147483647. /* 0x7FFFFFFF = Max. Int */
assign iTestInts[2] = -2147483648. /* 0x80000000 = Min. Int */
assign iTestInts[3] =           0. /* 0 */
assign iTestInts[4] =           ?. /* Null */
assign iTestInts[5] =          -1. /* 0xFFFFFFFF */
assign iTestInts[6] =           1. /* 0x00000001 */

do i = 1 to extent(iTestInts):
  message "Now validating " iTestInts[i].
end.
