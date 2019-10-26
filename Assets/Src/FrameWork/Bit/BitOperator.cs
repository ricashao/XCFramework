public class BitOperator
{
    public static int And(int a, int b){

        return a & b;
    }

    public static int Or(int a, int b)
    {
        return a | b;
    }

    public static int lMove(int a, int num)
    {
        return a << num;
    }

    public static int rMove(int a, int num)
    {
        return a >> num;
    }

    public static long And(long a, long b)
    {

        return a & b;
    }

    public static long Or(long a, long b)
    {
        return a | b;
    }

    public static long lMove(long a, int num)
    {
        return a << num;
    }

    public static long rMove(long a, int num)
    {
        return a >> num;
    }

}