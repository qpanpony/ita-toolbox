package ita.listeningTestGUI;


/// this class is basically just a wrapper around the ListeningTestMain class
/// this allows eclipse to interact the same way that matlab uses
public class eclipseWrapper {

	/**
	 * @param args
	 */
	public static void main(String[] args) {


		ListeningTestMain mainGUI = ListeningTestMain.getInstance();
		mainGUI.setControllerLimits(30, 150);
		mainGUI.setOnlyFeedback(1);
		mainGUI.show(0,".");
		mainGUI.setFeedback(0,90,2,270,80);
		mainGUI.setViewAzimuthAngle(90);
//		mainGUI.trainDirection(-30, 90, 10);
//		mainGUI.reset();
//		mainGUI.setFeedback(20,90,2,0,80);
//		mainGUI.trainDirection(0, 90, 10);
//		mainGUI.reset();
//		mainGUI.trainDirection(0, 90, 10);
//		mainGUI.reset();
//		mainGUI.trainDirection(0, 90, 10);
//		mainGUI.reset();
//		mainGUI.trainDirection(0, 90, 10);
//		mainGUI.reset();
//		mainGUI.trainDirection(0, 90, 10);
		//mainGUI.setFullscreen(1);
		//mainGUI.setControllerLimits(80, 110);
		

	}

}
