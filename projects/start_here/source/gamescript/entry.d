module gamescript.entry;
import hip.api;

/**
*	Call `dub` to generate the DLL, after that, just execute `dub -c run` for starting your project
*/
class MainScene : AScene, IHipPreloadable
{
    mixin Preload;
	IHipFont bigFont, smallFont;
	/** Constructor */
	override void initialize()
	{
		Viewport vp = getCurrentViewport();
		vp.setBounds(0, 0, 800, 600);
		setViewport(vp);

        smallFont = HipDefaultAssets.getDefaultFontWithSize(20);
        bigFont = HipDefaultAssets.getDefaultFontWithSize(64);
	}
	/** Called every frame */
	override void update(float dt)
	{
        if(HipInput.isMouseButtonJustPressed(HipMouseButton.left))
        {
            logg("You just clicked me!");
        }

        if(HipInput.isKeyJustPressed(HipKey.ENTER))
        {
            logg("Don't press ENTER!");
        }
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
        fillRectangle(0, 0, 200, 200, HipColorf.red);
        fillRectangle(0, 0, 100, 100, HipColorf.green);

        //Use a non GC allocating string on render (String) for drawing the mousePosition
        import hip.util.string;
        float[2] mousePos = HipInput.getWorldMousePosition();
        setFont(smallFont);
        String s = String(mousePos);
        drawText(s.toString, cast(int)mousePos[0], cast(int)mousePos[1]);

        

        ////////////////////////Higher Level////////////////////////
        setGeometryColor(HipColorf.white);
        setFont(null);
        drawText("Hello World Test Scene (Default Font)", 300, 280, HipColorf.white, HipTextAlign.LEFT, HipTextAlign.TOP);
        fillRectangle(300, 300, 100, 100);

        drawText("Null Textures uses that sprite over here", 300, 480, HipColorf.white, HipTextAlign.LEFT, HipTextAlign.TOP);
        drawTexture(null, 300, 500);

	}
	/** Pre destroy */
	override void dispose()
	{
		
	}

	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
