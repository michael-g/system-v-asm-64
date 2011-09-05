
public class HelloArgs {

	static {
		System.loadLibrary("hello");
	}

	public static void main(String[] args) throws Exception {
		System.out.println("Starting...");

		HelloArgs ha = new HelloArgs();
		ha.sayHello();

		System.out.println("Exiting...");
	}

	native void sayHello();

	void printMessage() {
		System.out.println("Hello, World!");
	}
}
