package ita.listeningTestGUI;

import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.BufferCapabilities.FlipContents;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.awt.GLCanvas;
import javax.media.opengl.GLEventListener;
import javax.media.opengl.glu.GLU;
import javax.swing.JFrame;
import javax.swing.WindowConstants;

import com.jogamp.opengl.util.FPSAnimator;
import com.jogamp.opengl.util.gl2.GLUT;
import com.jogamp.opengl.util.texture.Texture;
import com.jogamp.opengl.util.texture.TextureCoords;
import com.jogamp.opengl.util.texture.TextureIO;
import com.jogamp.opengl.util.awt.ImageUtil;

import static javax.media.opengl.GL.*; // GL constants
import static javax.media.opengl.GL2.*; // GL2 constants

// this is the main opengl class
// all different presentation methods should reimplement this
public abstract class MainGLWindowBasis implements GLEventListener {

	protected GLCanvas canvas = new GLCanvas();
	protected JFrame frame;

	protected FPSAnimator animator;
	protected static final int REFRESH_FPS = 60; // Display refresh frames per
													// second
	protected GLU glu; // For the GL Utility
	protected GLUT glut;

	// these objects keep trac of selected or otherwise important (highlighted)
	// places
	protected MarkedStruct isMarked = new MarkedStruct();
	protected MarkedStruct trainSection = new MarkedStruct();
	protected int inHeadLocalization = 0;

	protected float radius = 2.6f;

	// the colors, that different parts are drawn in
	protected ColorClass markedColor = new ColorClass(0, 1, 0, 0.5f); // green,
																		// alpha1
	protected ColorClass trainColor = new ColorClass(1, 0, 0, 0.5f); // red,
																		// alpha1
	protected ColorClass markedAndSelectedColor = new ColorClass(0, 1, 0, 0.9f); // green,
																					// alpha1
	protected ColorClass trainAndSelectedColor = new ColorClass(1, 0, 0, 0.9f); // red,
																				// alpha1
	protected ColorClass backgroundColor = new ColorClass(0, 0, 0, 0.2f);
	protected ColorClass searchColor = new ColorClass(0, 0, 0, 1.0f);

	protected ColorClass arrowColor = new ColorClass(0.9f, 0.5f, 0.2f, 0.95f);
	protected ColorClass arrowMarkedColor = new ColorClass(0.9f, 0.5f, 0.2f, 1f);

	protected ColorClass buttonColor = new ColorClass(0.4f, 0.2f, 0.3f, 0.2f);

	protected int dynamicAlphaMode = 1;

	protected int resolutionFactor = 10; // limits the maximal resolution to 0.1
											// == 1/resolutionFactor degree

	// input method
	protected abstractInput inputObject;
	protected OpenGLWindowAdapter windowAdapter;

	protected double windowWidth;
	protected double windowHeight;

	protected int isStarted = 0;

	protected Texture aTexture;
	protected Texture bTexture;
	protected Texture startTexture;
	protected Texture xTexture;
	protected Texture xTexture2;
	protected Texture trainTexture;

	protected File aImage;
	protected File bImage;
	protected File startImage;
	protected File xImage;
	protected File xImage2;
	protected File trainImage;

	protected int hideReplayButton = 0;

	protected float perspective = 0;

	protected int displayTrainMessage = 0;

	protected int elevationLowerLimit = 50;
	protected int elevationUpperLimit = 130;

	protected String texturePath = ".";
	
	protected int onlyFeedbackValue = 0;
	
	
	protected int viewAngle = 0;
	
	public MainGLWindowBasis(abstractInput event, OpenGLWindowAdapter wA) {
		inputObject = event;
		windowAdapter = wA;
	}

	// the display function is called with a certain framerate from the
	// animator.
	// all of the drawing is happening here
	public void display() {
	};
	
	public void setOnlyFeebackValue(int value)
	{
		onlyFeedbackValue = value;
	}
	
	public void setViewAngle(int value)
	{
		viewAngle = value;
	}
	
	// init the window and handle window closing
	public void show(int fullScreenValue, String path) {
		texturePath = path;
		// System.out.println(System.getProperty("java.vm.version"));
		frame = new JFrame("ITA Listeningtest GUI");
		canvas.addGLEventListener(this);

		frame.add(canvas);

		setFullscreen(fullScreenValue);

		frame.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
		frame.setVisible(true);
		frame.addWindowListener(windowAdapter);
		frame.requestFocus();
		// the animator calls the display function
		animator = new FPSAnimator(canvas, REFRESH_FPS, true);
		animator.start();
	};

	public boolean isVisible() {
		return frame.isVisible();
	}
	
	
	public void setVisible(boolean value){
		frame.setVisible(value);
	}
	public void close() {
		// ControllerManager.shutdown();
		 System.out.println("MainGLWindow.close");
		//frame.dispose();
	}

	public GLCanvas getCanvas() {
		return canvas;
	}

	@Override
	// some init functions.
	// this is mostly copied out of tutorials ;)
	public void init(GLAutoDrawable drawable) {
		// Get the OpenGL graphics context
		GL2 gl = drawable.getGL().getGL2();
		// GL Utilities
		glu = new GLU();
		glut = new GLUT();
		// Enable smooth shading, which blends colors nicely, and smoothes out
		// lighting.
		gl.glShadeModel(GL_SMOOTH);
		// Set background color in RGBA. Alpha: 0 (transparent) 1 (opaque)
		gl.glClearColor(1.0f, 1.0f, 1.0f, 0.0f);

		gl.glEnable(GL_BLEND);
		gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		// gl.glEnable(GL_COLOR_MATERIAL);
		gl.glDisable(GL_LIGHTING);
		

		// load images

		aImage = null;
		bImage = null;
		startImage = null;
		xImage = null;
		xImage2 = null;
		trainImage = null;
		try {
			aImage = new File(texturePath + "/img/aImage.png");
			bImage = new File(texturePath + "/img/bImage.png");
			startImage = new File(texturePath + "/img/startImage.png");
			xImage = new File(texturePath + "/img/xImage.png");
			xImage2 = new File(texturePath + "/img/xImage2.png");
			trainImage = new File(texturePath + "/img/trainImage.png");

			aTexture = TextureIO.newTexture(aImage, true);
			bTexture = TextureIO.newTexture(bImage, true);
			startTexture = TextureIO.newTexture(startImage, false);
			xTexture = TextureIO.newTexture(xImage, true);
			xTexture2 = TextureIO.newTexture(xImage2, true);
			trainTexture = TextureIO.newTexture(trainImage, true);

		} catch (IOException e) {
			e.printStackTrace();
		}

		// gl.glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE,
		// GL_REPLACE );

		gl.glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
		aTexture.enable(gl);
		bTexture.enable(gl);
		startTexture.enable(gl);
		xTexture.enable(gl);
		xTexture2.enable(gl);
		trainTexture.enable(gl);

	}

	// some basic function to draw a wireframe sphere with radius r and a given
	// resolution (not used at the moment)
	protected void drawSpere(GLAutoDrawable drawable, double r,
			double azimuthResolution, double elevationResolution, float alpha) {

		drawSpherePart(drawable, r, azimuthResolution, elevationResolution, 0,
				360, 0, 180, searchColor, GL_LINE, 0);
	}

	protected void drawOverlay(GLAutoDrawable drawable) {
		GL2 gl = drawable.getGL().getGL2();
//		gl.glPushAttrib(GL_ALL_ATTRIB_BITS);
		gl.glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		// 2d mode for overlay
		gl.glMatrixMode(GL_PROJECTION);
		gl.glLoadIdentity();
		gl.glOrtho(0.0, windowWidth, windowHeight, 0.0, -1.0, 10.0);
		gl.glMatrixMode(GL_MODELVIEW);
		// glPushMatrix(); ----Not sure if I need this
		gl.glLoadIdentity();
		gl.glDisable(GL_CULL_FACE);
		gl.glClear(GL_DEPTH_BUFFER_BIT);

		// paint 2d
		if (isStarted == 0) {
			drawButtonTexture(drawable, startTexture, 0.5f, 0.1f);
		} else {
			if (hideReplayButton == 0) {
				drawButtonTexture(drawable, bTexture, 0.9f, 0.75f);
			}

			drawButtonTexture(drawable, aTexture, 0.9f, 0.9f);

			if (perspective == 0) {
				drawButtonTexture(drawable, xTexture, 0.1f, 0.9f);
			} else {
				drawButtonTexture(drawable, xTexture2, 0.1f, 0.9f);
			}

			if (displayTrainMessage == 1) {
				drawButtonTexture(drawable, trainTexture, 0.1f, 0.75f);
			}
		}

		// reset opengl to 3d mode
		gl.glMatrixMode(GL_PROJECTION);
		gl.glLoadIdentity(); // reset
		float aspect = (float) (windowWidth / windowHeight);
		glu.gluPerspective(45f, aspect, 0.1f, 100.0f);
		gl.glMatrixMode(GL_MODELVIEW);
		gl.glLoadIdentity();
		gl.glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
//		gl.glPopAttrib();
	}

	protected void drawButtonTexture(GLAutoDrawable drawable, Texture texture,
			double xPercent, double yPercent) {
		float boxWidth = 0.1f;
		float boxHeight = 0.1f;

		GL2 gl = drawable.getGL().getGL2();

		gl.glPushMatrix();
		gl.glTranslated(xPercent * windowWidth, yPercent * windowHeight, 0);

		float left = 0;
		float top = 0;
		float width = boxWidth;
		float height = boxHeight;

		texture.bind(gl);

		gl.glBegin(GL_QUADS);
		gl.glNormal3f(0, 0, 1);
		 gl.glTexCoord2d(0.0, 1.0);
		 gl.glVertex2d((0.0f - boxWidth / 2) * windowWidth,
		 (0.0f - boxHeight / 2) * windowHeight);
		 gl.glTexCoord2d(1.0, 1.0);
		 gl.glVertex2d((0.1f - boxWidth / 2) * windowWidth,
		 (0.0f - boxHeight / 2) * windowHeight);
		 gl.glTexCoord2d(1.0, 0.0);
		 gl.glVertex2d((0.1f - boxWidth / 2) * windowWidth,
		 (0.1f - boxHeight / 2) * windowHeight);
		 gl.glTexCoord2d(0.0, 0.0);
		 gl.glVertex2d((0.0f - boxWidth / 2) * windowWidth,
		 (0.1f - boxHeight / 2) * windowHeight);

		gl.glEnd();

		gl.glPopMatrix();

	}

	protected void drawButton(GLAutoDrawable drawable, ColorClass color,
			double xPercent, double yPercent, String buttonString,
			String explString) {
		float boxWidth = 0.1f;
		float boxHeight = 0.1f;
		GL2 gl = drawable.getGL().getGL2();
		gl.glPushMatrix();
		gl.glTranslated(xPercent * windowWidth, yPercent * windowHeight, 0);

		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		gl.glBegin(GL_QUADS);
		gl.glColor4f(color.colorArray[0], color.colorArray[1],
				color.colorArray[2], color.colorArray[3]);
		gl.glVertex2d((0.0f - boxWidth / 2) * windowWidth,
				(0.0f - boxHeight / 2) * windowHeight);
		gl.glVertex2d((0.1f - boxWidth / 2) * windowWidth,
				(0.0f - boxHeight / 2) * windowHeight);
		gl.glVertex2d((0.1f - boxWidth / 2) * windowWidth,
				(0.1f - boxHeight / 2) * windowHeight);
		gl.glVertex2d((0.0f - boxWidth / 2) * windowWidth,
				(0.1f - boxHeight / 2) * windowHeight);
		gl.glEnd();

		gl.glRasterPos2i(5, 5);
		glut.glutBitmapString(GLUT.BITMAP_HELVETICA_12, buttonString); // Print
																		// a
																		// character
																		// on
																		// the
																		// screen
		gl.glRasterPos2i(5, 20);
		glut.glutBitmapString(GLUT.BITMAP_HELVETICA_12, explString);

		gl.glPopMatrix();
	}

	// this draws the "background" a hemisphere for orientation, based on your
	// input orientation
	// if the controller is in idle state, a "reference" should be displayed to
	// allow easy orientation
	protected void drawBackground(GLAutoDrawable drawable, double azimuth,
			double magnitude) {
		drawCircle(drawable, radius, 10, new ColorClass(0.0f, 0.4f, 1.0f, 0.2f));
		drawCircleMarkers(drawable, radius, 30);
		// lable axes
		drawAzimuthText(drawable, radius, 30);

		if (magnitude < 0.5) {
			GL2 gl = drawable.getGL().getGL2();
			gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
			gl.glColor4f(1.0f, 1.0f, 0.0f, 0.1f);
			drawFullArrow(drawable, 1);
		}
	}

	protected void drawFullArrow(GLAutoDrawable drawable, float length) {
		ColorClass color = arrowColor;
		// draw the arrow before the text to avoid overlays
		// the arrow color depends on the selection mode of the arrow
		if (getInHeadLocalization() == 1) {
			color = arrowMarkedColor;
		}
		drawArrow(drawable, length, color);
//		if (getInHeadLocalization() == 1) {
//			drawInHeadText(drawable);
//		}
	}

	protected void drawArrow(GLAutoDrawable drawable, float length,
			ColorClass color) {
		GL2 gl = drawable.getGL().getGL2();
		gl.glColor4f(color.colorArray[0], color.colorArray[1],
				color.colorArray[2], color.colorArray[3]);

		gl.glBegin(GL_TRIANGLE_FAN);

		gl.glVertex3f(length / 2, 0, 0);
		gl.glVertex3f(length / 8, -length / 3, 0);
		gl.glVertex3f(length / 8, length / 3, 0);

		gl.glEnd();

		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

		gl.glBegin(GL_QUAD_STRIP);

		gl.glVertex3f(length / 8, -length / 7, 0);
		gl.glVertex3f(length / 8, length / 7, 0);
		gl.glVertex3f(-length / 2, -length / 7, 0);
		gl.glVertex3f(-length / 2, length / 7, 0);

		gl.glEnd();
	}

	// Label the Circlemarkers
	protected void drawAzimuthText(GLAutoDrawable drawable, float radius,
			int resolution) {
		GL2 gl = drawable.getGL().getGL2();
		gl.glColor3f(0.0f, 0.2f, 0.6f);

		int height = drawable.getSurfaceHeight();
		int width = drawable.getSurfaceWidth();
		int font = GLUT.BITMAP_HELVETICA_18;

		float xPos = 0;
		float yPos = 0;

		if (height <= 300 || width <= 300) {
			font = GLUT.BITMAP_HELVETICA_10;
		} else if (height <= 500 || width <= 500) {
			font = GLUT.BITMAP_HELVETICA_12;
		}
		for (int azimuthAngle = 0; azimuthAngle < 360; azimuthAngle += resolution) {
			xPos = (float) (0.65 * radius * Math.cos(Math.PI * azimuthAngle
					/ 180));
			yPos = (float) (0.65 * radius * Math.sin(Math.PI * azimuthAngle
					/ 180));
			String azimuthText = String.valueOf(azimuthAngle);
			azimuthText += "�";

			gl.glRasterPos2f(xPos, yPos);
			glut.glutBitmapString(font, azimuthText);
		}
	}

	// This function labels the "inHead-Arrow"
	protected void drawInHeadText(GLAutoDrawable drawable) {
		GL2 gl = drawable.getGL().getGL2();
		// TODO find the right color for this
		gl.glColor3f(0.5f, 0.0f, 0.8f);
		// gl.glColor3f(0.0f, 0.0f, 0.0f);

		int height = drawable.getSurfaceHeight();
		int width = drawable.getSurfaceWidth();
		int font = GLUT.BITMAP_HELVETICA_18;
		// float yPos = 0.3f;

		if (height <= 300 || width <= 300) {
			font = GLUT.BITMAP_HELVETICA_10;
			// yPos = 0.2f;
		} else if (height <= 500 || width <= 500) {
			font = GLUT.BITMAP_HELVETICA_12;
			// yPos = 0.06f;
		}

		gl.glRasterPos3f(0, 0, 0.15f);
		glut.glutBitmapString(font, "InHead");

	}

	// the main function used in the basisglmode
	// draws part of a sphere
	/**
	 * @param drawable
	 * @param r
	 *            - the sphere radius
	 * @param azimuthResolution
	 *            - the resolution, aka how far the points are apart
	 * @param elevationResolution
	 * @param azimuthStart
	 *            - azimuth angle start of the drawn sphere
	 * @param azimuthEnd
	 * @param elevationStart
	 * @param elevationEnd
	 * @param color
	 *            - the color
	 * @param glOption
	 *            - this can be either GL_FILL or GL_LINE for filled or
	 *            wireframe model
	 * @param offset
	 *            - offsets the drawn squares so that the point is in the middle
	 *            of the square (ie for the crossair)
	 */
	protected void drawSpherePart(GLAutoDrawable drawable, double r,
			double azimuthResolution, double elevationResolution,
			double azimuthStart, double azimuthEnd, double elevationStart,
			double elevationEnd, ColorClass color, int glOption, int offset) {
		int azimuthIndex = 0;
		int elevationIndex = 0;

		double azimuth;
		double elevation;
		double nextElevation;
		double cosAzimuth;
		double sinAzimuth;
		double sinElevation;
		double sinNextElevation;
		double cosElevation;
		double cosNextElevation;
		float x;
		float y;
		float z;
		float nextX;
		float nextY;
		float nextZ;

		GL2 gl = drawable.getGL().getGL2();
		gl.glLineWidth(2);
		gl.glClear(GL_DEPTH_BUFFER_BIT);
		gl.glPolygonMode(GL_FRONT_AND_BACK, glOption);

		// because of the stupid resolution factor thing, everything is more
		// complicated than it needs to be
		int internalElevationStart = (int) (elevationStart * resolutionFactor);
		int internalElevationEnd = (int) (elevationEnd * resolutionFactor);
		int internalAzimuthStart = (int) (azimuthStart * resolutionFactor);
		int internalAzimuthEnd = (int) (azimuthEnd * resolutionFactor);

		if (offset == 1) {
			internalElevationStart -= elevationResolution * resolutionFactor
					/ 2;
			internalElevationEnd -= elevationResolution * resolutionFactor / 2;
			internalAzimuthStart -= azimuthResolution * resolutionFactor / 2;
			internalAzimuthEnd -= azimuthResolution * resolutionFactor / 2;
		}

		// because of the quad_strip option, a ring of points on two elevation
		// levels is drawn.
		for (elevationIndex = internalElevationStart; elevationIndex < internalElevationEnd; elevationIndex += elevationResolution
				* resolutionFactor) 
		{
			gl.glBegin(GL_QUAD_STRIP);
			gl.glColor4f(color.colorArray[0], color.colorArray[1],
					color.colorArray[2], color.colorArray[3]);
			elevation = Math.PI * elevationIndex / (180 * resolutionFactor);
			sinElevation = Math.sin(elevation);
			cosElevation = Math.cos(elevation);

			nextElevation = Math.PI
					* (elevationIndex + elevationResolution * resolutionFactor)
					/ (180 * resolutionFactor);
			sinNextElevation = Math.sin(nextElevation);
			cosNextElevation = Math.cos(nextElevation);

			for (azimuthIndex = internalAzimuthStart; azimuthIndex <= internalAzimuthEnd; azimuthIndex += azimuthResolution
					* resolutionFactor) {
				azimuth = Math.PI * azimuthIndex / (180 * resolutionFactor);
				cosAzimuth = Math.cos(azimuth);
				sinAzimuth = Math.sin(azimuth);

				x = (float) (r * sinElevation * cosAzimuth);
				y = (float) (r * sinElevation * sinAzimuth);
				z = (float) (r * cosElevation);

				nextX = (float) (r * sinNextElevation * cosAzimuth);
				nextY = (float) (r * sinNextElevation * sinAzimuth);
				nextZ = (float) (r * cosNextElevation);

				gl.glNormal3f(x, y, z);
				gl.glVertex3f(x, y, z);
				gl.glNormal3f(nextX, nextY, nextZ);
				gl.glVertex3f(nextX, nextY, nextZ);
			}
			// end drawing after each ring to avoid strange lines
			gl.glEnd();
			
		}
		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}

	// this draws a circle with radius r. the higher the resolution, the rounder
	// the circle will get
	protected void drawCircle(GLAutoDrawable drawable, float radius,
			int resolution, ColorClass color) {
		GL2 gl = drawable.getGL().getGL2();

		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

		gl.glBegin(GL_TRIANGLE_STRIP);
		gl.glColor4f(color.colorArray[0], color.colorArray[1],
				color.colorArray[2], color.colorArray[3]);

		int azimuthIndex = 0;

		double azimuth;

		double cosAzimuth;
		double sinAzimuth;
		float x;
		float y;

		gl.glNormal3f(radius, 0, 0);
		gl.glVertex3f(radius, 0, 0);
		for (azimuthIndex = resolution; azimuthIndex <= 360; azimuthIndex += resolution) {

			azimuth = Math.PI * azimuthIndex / (180);
			cosAzimuth = Math.cos(azimuth);
			sinAzimuth = Math.sin(azimuth);

			x = (float) (radius * cosAzimuth);
			y = (float) (radius * sinAzimuth);

			gl.glNormal3f(x, y, 0);
			gl.glVertex3f(x, y, 0);
			gl.glNormal3f(0, 0, 0);
			gl.glVertex3f(0, 0, 0);
		}
		gl.glEnd();
	}

	protected void drawCircleLinePart(GLAutoDrawable drawable, float radius,
			int resolution, double elevation, int minAzimuth, int maxAzimuth,
			ColorClass color) {
		GL2 gl = drawable.getGL().getGL2();

		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

		gl.glBegin(GL_LINE_STRIP);
		gl.glColor4f(color.colorArray[0], color.colorArray[1],
				color.colorArray[2], color.colorArray[3]);

		int azimuthIndex = 0;

		double azimuth;

		double cosAzimuth;
		double sinAzimuth;
		double sinElevation;
		double cosElevation;
		float x;
		float y;
		float z;
		elevation = Math.PI * elevation / 180;
		// gl.glNormal3f(radius,0,0);
		// gl.glVertex3f(radius,0,0);
		for (azimuthIndex = minAzimuth; azimuthIndex <= maxAzimuth; azimuthIndex += resolution) {

			azimuth = Math.PI * azimuthIndex / (180);

			cosAzimuth = Math.cos(azimuth);
			sinAzimuth = Math.sin(azimuth);
			sinElevation = Math.sin(elevation);
			cosElevation = Math.cos(elevation);

			x = (float) (radius * sinElevation * cosAzimuth);
			y = (float) (radius * sinElevation * sinAzimuth);
			z = (float) (radius * cosElevation);

			gl.glNormal3f(x, y, z);
			gl.glVertex3f(x, y, z);
			// gl.glNormal3f(0,0,0);
			// gl.glVertex3f(0,0,0);
		}
		gl.glEnd();
		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}

	protected void drawHorizontalCircleLine(GLAutoDrawable drawable,
			float radius, int resolution, double azimuth, double minElevation,
			double maxElevation, ColorClass color) {
		GL2 gl = drawable.getGL().getGL2();

		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

		gl.glBegin(GL_LINE_STRIP);
		gl.glColor4f(color.colorArray[0], color.colorArray[1],
				color.colorArray[2], color.colorArray[3]);

		azimuth = Math.PI * azimuth / (180);

		double elevationIndex = 0;
		double elevation = 0;
		double cosAzimuth;
		double sinAzimuth;
		double sinElevation;
		double cosElevation;
		float x;
		float y;
		float z;

		// gl.glNormal3f(radius,0,0);
		// gl.glVertex3f(radius,0,0);
		for (elevationIndex = minElevation; elevationIndex <= maxElevation; elevationIndex += resolution) {

			elevation = Math.PI * elevationIndex / 180;
			cosAzimuth = Math.cos(azimuth);
			sinAzimuth = Math.sin(azimuth);
			sinElevation = Math.sin(elevation);
			cosElevation = Math.cos(elevation);

			x = (float) (radius * sinElevation * cosAzimuth);
			y = (float) (radius * sinElevation * sinAzimuth);
			z = (float) (radius * cosElevation);

			gl.glNormal3f(x, y, z);
			gl.glVertex3f(x, y, z);
			// gl.glNormal3f(0,0,0);
			// gl.glVertex3f(0,0,0);
		}
		gl.glEnd();
		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

	}

	// some markers used on the circle
	protected void drawCircleMarkers(GLAutoDrawable drawable, float radius,
			int resolution) {
		GL2 gl = drawable.getGL().getGL2();

		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

		gl.glBegin(GL_LINES);
		gl.glColor4f(0.0f, 0.0f, 0.0f, 0.5f);

		int azimuthIndex = 0;

		double azimuth;

		double cosAzimuth;
		double sinAzimuth;
		float x;
		float y;

		// gl.glNormal3f(r,0,0);
		// gl.glVertex3f(r,0,0);
		for (azimuthIndex = resolution; azimuthIndex <= 360; azimuthIndex += resolution) {

			azimuth = Math.PI * azimuthIndex / (180);
			cosAzimuth = Math.cos(azimuth);
			sinAzimuth = Math.sin(azimuth);

			x = (float) (radius * cosAzimuth);
			y = (float) (radius * sinAzimuth);

			gl.glNormal3f(x, y, 0);
			gl.glVertex3f(x, y, 0);
			gl.glNormal3f(0, 0, 0);
			gl.glVertex3f(0, 0, 0);
		}
		gl.glEnd();
		gl.glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}

	protected void drawDirectionText(GLAutoDrawable drawable, float radius,
			double azimuth, double elevation) {

		GL2 gl = drawable.getGL().getGL2();
		gl.glColor3f(0.0f, 0.0f, 0.0f);

		String directionString = "El. ";
		directionString = directionString.concat(String
				.valueOf((int) elevation));

		gl.glRasterPos2f(1, 0);
		glut.glutBitmapString(GLUT.BITMAP_HELVETICA_12, directionString);

		directionString = "Ax. ";
		directionString = directionString.concat(String.valueOf((int) azimuth));

		gl.glRasterPos2f(1, 1);
		glut.glutBitmapString(GLUT.BITMAP_HELVETICA_12, directionString);

	}

	// set the marked mark
	// if the mark is on the same area as a previous mark, a confirmation event
	// is send and the gui is reset
	public void markSelectedSection(double azimuth, double elevation,
			int isStarted) {
		// case 1: no training, not marked
		// case 2: no trainning: marked
		// case 3: training, not marked
		// case 4: training, marked not within borders
		// case 5: training, marked within borders
		int sendSignal = 0;

		if (isStarted == 1) {
			if (trainSection.isMarked == 0) {
				if (isMarked.checkMarked(azimuth, elevation) == 0) {
					// case 1
					isMarked.mark(azimuth, elevation);
					markInHeadLocalization(0, 0);
				} else {
					// case 2
					sendSignal = 1;
				}
			} else {
				if (trainSection.isWithinMarkedArea(azimuth, elevation) == 1) {
					if (trainSection.isWithinMarkedArea(isMarked.markedAzimuth,
							isMarked.markedElevation) == 1) {
						// case 5
						sendSignal = 1;
					} else {
						// case 4
						isMarked.mark(azimuth, elevation);
						markInHeadLocalization(0, 0);
					}

				} else {
					// case 3
					isMarked.mark(azimuth, elevation);
					markInHeadLocalization(0, 0);
					displayTrainMessage = 1;
				}
			}
		}

		if (sendSignal == 1) {
			inputObject.getEventObject().notifyMousePressEvent(azimuth,
					elevation, 0);
			reset();
		}
	}

	// sets the trainings mark
	public void trainSection(double azimuth, double elevation, int width) {
		trainSection.mark(azimuth, elevation);
		trainSection.setFieldWidth(width);
		trainSection.setAdditionalMarkWidth(2);
	}

	// reset the gui
	public void reset() {
		//animator.stop();
		isMarked.reset();
		trainSection.reset();
		inputObject.reset();
		markInHeadLocalization(0, 0);
		//animator.start();
		displayTrainMessage = 0;
		perspective = 0;
		inputObject.setInvertedPerspective(0);
		// inHeadLocalization = 0;
	}

	// something something resize
	public void reshape(GLAutoDrawable drawable, int x, int y, int width,
			int height) {
		GL2 gl = drawable.getGL().getGL2();

		height = (height == 0) ? 1 : height; // prevent divide by zero
		float aspect = (float) width / height;

		windowWidth = width;
		windowHeight = height;
		// Set the current view port to cover full screen
		gl.glViewport(0, 0, width, height);

		// Set up the projection matrix - choose perspective view
		gl.glMatrixMode(GL_PROJECTION);
		gl.glLoadIdentity(); // reset
		// Angle of view (fovy) is 45 degrees (in the up y-direction). Based on
		// this
		// canvas's aspect ratio. Clipping z-near is 0.1f and z-near is 100.0f.
		glu.gluPerspective(45f, aspect, 0.1f, 100.0f); // fovy, aspect, zNear,
														// zFar
		// glu.gluLookAt(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
		// Enable the model-view transform
		gl.glMatrixMode(GL_MODELVIEW);
		gl.glLoadIdentity(); // reset
	}

	public void displayChanged(GLAutoDrawable drawable, boolean modeChanged,
			boolean deviceChanged) {
	}

	public void setNewBlocks(int numberOfBlocks, float[] azimuthValues,
			float[] elevationValues, float[] blockWidth, float[] additionalWidth) {
		// TODO Auto-generated method stub

	}

	public void setDynamicAlphaMode(int value) {
		dynamicAlphaMode = value;
	}

	public void markInHeadLocalization(int value, int isStarted) {

		if (value == 0) {
			inHeadLocalization = value;
		} else if (inHeadLocalization == 0) {
			inHeadLocalization = value;
		}
		// confirm inHeadLocalization
		else if (inHeadLocalization == 1) {
			if (isStarted == 1) {
				inputObject.getEventObject().notifyMousePressEvent(0, 0, 1);
			}
			reset();
		}

	}

	public int getInHeadLocalization() {
		return inHeadLocalization;
	}

	public void setIsStarted(int value) {
		isStarted = value;
	}

	public void setHideReplayButton(int value) {
		hideReplayButton = value;
	}

	public void changePerspective() {
		perspective = perspective + 180;
		perspective = perspective % 360;

		if (perspective == 180) {
			inputObject.setInvertedPerspective(1);
		} else {
			inputObject.setInvertedPerspective(0);
		}
	}

	public void showTrainMessage(int value) {
		displayTrainMessage = value % 2;
	}

	public void setFullscreen(int value) {
		if (value == 1) 
		{
			GraphicsDevice gd = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
			int width = gd.getDisplayMode().getWidth();
			int height = gd.getDisplayMode().getHeight();
			frame.setSize(width, height);
			frame.setUndecorated(true);

		} else {
			GraphicsDevice gd = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
			int width = gd.getDisplayMode().getWidth();
			int height = gd.getDisplayMode().getHeight();
			frame.setSize(width, height);
			frame.setUndecorated(false);
		}

	}

	protected void drawText(GLAutoDrawable drawable, float radius,
			double azimuth, double elevation, String text) {
		// GL2 gl = drawable.getGL().getGL2();
		// gl.glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
		//
		// elevation = Math.PI*elevation/180;
		// azimuth = Math.PI*azimuth/180;
		// double cosAzimuth = Math.cos (azimuth);
		// double sinAzimuth = Math.sin(azimuth);
		// double sinElevation = Math.sin(elevation);
		// double cosElevation = Math.cos(elevation);
		//
		// float x = (float) (radius*sinElevation * cosAzimuth);
		// float y = (float) (radius*sinElevation * sinAzimuth);
		// float z = (float) (radius*cosElevation);
		//
		//
		//
		// TextRenderer textr = new TextRenderer(new Font("SansSerif",
		// Font.BOLD, 10));
		// textr.setColor(1.0f, 0.2f, 0.2f, 0.8f);
		//
		// gl.glMatrixMode(GL_MODELVIEW);
		// gl.glPushMatrix();
		//
		// gl.glRotatef(90,1,0,0);
		// gl.glRotatef(-90,0,1,0);
		// textr.begin3DRendering();
		// textr.draw3D("90�", 0, 0, 0, (float) 1);
		// textr.end3DRendering();
		// gl.glPopMatrix();

		elevation = Math.PI * elevation / 180;
		azimuth = Math.PI * azimuth / 180;
		double cosAzimuth = Math.cos(azimuth);
		double sinAzimuth = Math.sin(azimuth);
		double sinElevation = Math.sin(elevation);
		float x = (float) (radius * sinElevation * cosAzimuth);
		float y = (float) (radius * sinElevation * sinAzimuth);
		GL2 gl = drawable.getGL().getGL2();
		// TODO find the right color for this
		gl.glColor3f(0.5f, 0.0f, 0.8f);
		// gl.glColor3f(0.0f, 0.0f, 0.0f);

		int height = drawable.getSurfaceHeight();
		int width = drawable.getSurfaceWidth();
		int font = GLUT.BITMAP_HELVETICA_18;
		// float yPos = 0.3f;

		if (height <= 300 || width <= 300) {
			font = GLUT.BITMAP_HELVETICA_10;
			// yPos = 0.2f;
		} else if (height <= 500 || width <= 500) {
			font = GLUT.BITMAP_HELVETICA_12;
			// yPos = 0.06f;
		}

		gl.glRasterPos3f(x, y, 0.15f);
		glut.glutBitmapString(font, text);

	}
	public void finalize()
    {
    	System.out.println("OpenGL.finalize");
    }
}
