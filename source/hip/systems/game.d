/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.systems.game;
import hip.hiprenderer.renderer;
import hip.global.gamedef;
private import hip.event.dispatcher;
private import hip.event.handlers.keyboard;
import hip.view;
import hip.windowing.events;
import hip.graphics.g2d.renderer2d;


version(LoadScript)
{
    import hip.systems.hotload;
    import hip.systems.compilewatcher;
    import std.typecons:Tuple;
    private bool getDubError(Tuple!(int, "status", string, "output") dubObj, out string err)
    {
        import hip.console.log;
        if(dubObj.status != 2)
        {
            import core.stdc.stdlib:exit;
            import std.stdio;
            writeln("Dub error: ", dubObj);
            exit(1); 
        }
        else
        {
            import hip.util.string:indexOf, lastIndexOf;
            int errInd = dubObj.output.indexOf("Warning:");
            if(errInd == -1)
                errInd = dubObj.output.indexOf("Error:"); //Check first for warnings
            if(errInd == -1) return false;
            errInd = dubObj.output.lastIndexOf("\n", errInd)-1;
            err = dubObj.output[errInd..$];
            return true;
        }
    }
    extern(C) AScene function() HipremeEngineGameInit;
    extern(C) void function() HipremeEngineGameDestroy;
}


class GameSystem
{
    /** 
     * Holds the member that generates the events as inputs
     */
    EventDispatcher dispatcher;
    KeyboardHandler keyboard;
    AScene[] scenes;
    string projectDir;
    protected static AScene externalScene;

    version(LoadScript)
    {
        static CompileWatcher watcher;
        protected static HotloadableDLL hotload;
    }
    bool hasFinished;
    float fps;

    float targetFPS;

    this(float targetFPS)
    {
        this.targetFPS = targetFPS;
        keyboard = new KeyboardHandler();
        keyboard.addKeyListener(HipKey.ESCAPE, new class HipButton
        {
            override void onDown(){hasFinished = true;}
            override void onUp(){}
        });

        keyboard.addKeyListener(HipKey.F1, new class HipButton
        {
            override void onDown(){}
            override void onUp(){import hip.bind.interpreters; reloadInterpreter();}
        });

        version(LoadScript)
        {
            keyboard.addKeyListener(HipKey.F5, new class HipButton
            {
                override void onDown()
                {}
                override void onUp()
                {
                    import hip.console.log;
                    rawlog("Recompiling and Reloading game ");
                    recompileReloadExternalScene();
                }
            });
        }

        dispatcher = new EventDispatcher(HipRenderer.window, &keyboard);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.width = width;
            HipRenderer.height = height;
            resizeRenderer2D(width, height);
            foreach (AScene s; scenes)
                s.onResize(width, height);
        });
        
    }

    void loadGame(string gameDll)
    {
        version(LoadScript)
        {
            import hip.filesystem.hipfs;
            import hip.util.path;
            import hip.util.system;
            import hip.util.string:indexOf;


            if(gameDll.isAbsolutePath && HipFS.absoluteIsFile(gameDll))
            {
                projectDir = gameDll.dirName;
            }
            else if(!gameDll.extension && gameDll.indexOf("projects/") == -1)
            {
                projectDir = joinPath("projects", gameDll);
                gameDll = joinPath("projects", gameDll, gameDll);
            }
            else
                projectDir = gameDll;

            watcher = new CompileWatcher(projectDir, null, ["d"]).run;

            hotload = new HotloadableDLL(gameDll, (void* lib)
            {
                assert(lib != null, "No library " ~ gameDll ~ " was found");
                HipremeEngineGameInit = 
                    cast(typeof(HipremeEngineGameInit))
                    dynamicLibrarySymbolLink(lib, "HipremeEngineGameInit");
                assert(HipremeEngineGameInit != null,
                "HipremeEngineGameInit wasn't found when looking into "~gameDll);
                HipremeEngineGameDestroy = 
                    cast(typeof(HipremeEngineGameDestroy))
                    dynamicLibrarySymbolLink(lib, "HipremeEngineGameDestroy");
                assert(HipremeEngineGameDestroy != null,
                "HipremeEngineGameDestroy wasn't found when looking into "~gameDll);
            });
        }
    }

    void recompileGame()
    {
        version(LoadScript)
        {
            import std.process:executeShell;
            import std.stdio;
            auto dub = executeShell("cd "~projectDir~" && dub");

            writeln(projectDir);
            writeln(dub);
            
            //2 == up to date
            string err;
            if(getDubError(dub, err))
            {
                import core.sys.windows.winuser;
                MessageBoxA(null, (err~"\0").ptr, "GameDLL Compilation Failure\0".ptr,  MB_ICONERROR | MB_OK);
            }
            hotload.reload();
        }
    }

    void startExternalGame()
    {
        version(Test)
        {
            // addScene(new SoundTestScene());
            // addScene(new ChainTestScene());
            // addScene(new AssetTest());
            import hip.view.ttftestscene;
            addScene(new TTFTestScene());
        }
        else version(LoadScript)
        {
            assert(HipremeEngineGameInit != null, "No game was loaded");
            externalScene = HipremeEngineGameInit();
            addScene(externalScene);
        }
        else version(Standalone)
        {
            import hip.script.entry;
            externalScene = new HipEngineMainScene();
            addScene(externalScene);
        }
    }

    void recompileReloadExternalScene()
    {
        version(LoadScript)
        {
            import hip.util.array:remove;
            import hip.console.log;
            if(hotload)
            {
                rawlog("Recompiling game");
                HipremeEngineGameDestroy();
                scenes.remove(externalScene);
                externalScene = null;
                recompileGame(); // Calls hotload.reload();
                startExternalGame();
            }
        }
    }

    

    void addScene(AScene s)
    {
        import hip.console.log;
        logln("Initializing scene ", s.getName);
    	s.init();
        scenes~= s;
    }

    bool update(float deltaTime)
    {
        version(LoadScript)
        {
            if(watcher.update())
                recompileReloadExternalScene();
        }
        dispatcher.handleEvent();
        dispatcher.pollGamepads(deltaTime);

        if(hasFinished || dispatcher.hasQuit)
            return false;
        foreach(s; scenes)
            s.update(deltaTime);

        return true;
    }
    void render()
    {
        foreach (AScene s; scenes)
            s.render();
    }
    void postUpdate()
    {
        dispatcher.postUpdate();
    }
    
    void quit()
    {
        version(LoadScript)
        {
            if(hotload !is null)
            {
                if(HipremeEngineGameDestroy != null)
                    HipremeEngineGameDestroy();
                destroy(watcher);
                scenes.length = 0;
                externalScene = null;
                hotload.dispose();
            }
        }
    }
}