/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

/**
*   This class will be only a wrapper for importing the correct backend
*/
module hiprenderer.texture;
import data.assetmanager;
import error.handler;
import hiprenderer.renderer;
import bindbc.sdl;
import data.image;
public import util.data_structures:Array2D;

enum TextureWrapMode
{
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    REPEAT,
    MIRRORED_REPEAT,
    MIRRORED_CLAMP_TO_EDGE,
    UNKNOWN
}

enum TextureFilter
{
    LINEAR,
    NEAREST,
    NEAREST_MIPMAP_NEAREST,
    LINEAR_MIPMAP_NEAREST,
    NEAREST_MIPMAP_LINEAR,
    LINEAR_MIPMAP_LINEAR
}
interface ITexture
{
    void setWrapMode(TextureWrapMode mode);
    void setTextureFilter(TextureFilter min, TextureFilter mag);
    bool load(Image img);
    void bind();
}

class Texture
{
    Image img;
    uint width,height;
    TextureFilter min, mag;

    protected ITexture textureImpl;
    /**
    *   Initializes with the current renderer type
    */
    protected this()
    {
        textureImpl = HipRenderer.getTextureImplementation();
    }


    this(string path = "")
    {
        this();
        if(path != "")
            load(path);
    }
    /** Binds as the texture target on the renderer. */
    public void bind(){textureImpl.bind();}
    public void setWrapMode(TextureWrapMode mode){textureImpl.setWrapMode(mode);}
    public void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        this.min = min;
        this.mag = mag;
        textureImpl.setTextureFilter(min, mag);
    }
    
    SDL_Rect getBounds(){return SDL_Rect(0,0,width,height);}
    void render(int x, int y){HipRenderer.draw(this, x, y);}

    /**
    *   Returns whether the load was successful
    */
    public bool load(string path)
    {
        HipAssetManager.loadImage(path, (Image img)
        {
            this.img = img;
            this.width = img.w;
            this.height = img.h;
            this.textureImpl.load(img);
        }, false);
        return this.width != 0;
    }



}



class TextureRegion
{
    Texture texture;
    public float u1, v1, u2, v2;
    protected float[8] vertices;
    int regionWidth, regionHeight;

    this(string texturePath, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
    {
        texture = new Texture(texturePath);
        setRegion(u1,v1,u2,v2);
    }

    this(Texture texture, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
    {
        this.texture = texture;
        setRegion(u1,v1,u2,v2);
    }
    this(Texture texture, uint u1, uint v1, uint u2, uint v2)
    {
        this.texture = texture;
        setRegion(texture.width, texture.height, u1,  v1, u2, v2);
    }

    ///By passing the width and height values, you'll be able to crop useless frames
    public static Array2D!TextureRegion spritesheet(
        Texture t,
        uint frameWidth, uint frameHeight,
        uint width, uint height,
        uint offsetX, uint offsetY,
        uint offsetXPerFrame, uint offsetYPerFrame)
    {
        uint lengthW = width/(frameWidth+offsetXPerFrame);
        uint lengthH = height/(frameHeight+offsetYPerFrame);

        Array2D!TextureRegion ret = Array2D!TextureRegion(lengthH, lengthW);

        for(int i = 0, fh = 0; fh < height; i++, fh+= frameHeight+offsetXPerFrame)
            for(int j = 0, fw = 0; fw < width; j++, fw+= frameWidth+offsetYPerFrame)
                ret[i,j] = new TextureRegion(t, offsetX+fw , offsetY+fh, offsetX+fw+frameWidth, offsetY+fh+frameHeight);

        return ret;
    }
    ///Default spritesheet method that makes a spritesheet from the entire texture
    static Array2D!TextureRegion spritesheet(Texture t, uint frameWidth, uint frameHeight)
    {
        return spritesheet(t,frameWidth,frameHeight, t.width, t.height, 0, 0, 0, 0);
    }

     /**
    *   Defines a region for the texture in the following order:
    *   Top-left
    *   Top-Right
    *   Bot-Right
    *   Bot-Left
    */
    public void setRegion(float u1, float v1, float u2, float v2)
    {
        this.u1 = u1;
        this.u2 = u2;
        this.v1 = v1;
        this.v2 = v2;
        regionWidth =  cast(uint)((texture.width*u2) -(texture.width*u1));
        regionHeight = cast(uint)((texture.height*v2)-(texture.height*v1));

        //Top left
        vertices[0] = u1;
        vertices[1] = v1;

        //Top right
        vertices[2] = u2;
        vertices[3] = v1;
        
        //Bot right
        vertices[4] = u2;
        vertices[5] = v2;

        //Bot left
        vertices[6] = u1;
        vertices[7] = v2;
    }

    ///Sets the region based on the width and height for it being more friendly
    void setRegion(uint width, uint height, uint u1, uint v1, uint u2, uint v2)
    {
        float fu1 = u1/cast(float)width;
        float fu2 = u2/cast(float)width;
        float fv1 = v1/cast(float)height;
        float fv2 = v2/cast(float)height;
        setRegion(fu1, fv1, fu2, fv2);
    }

    void setRegion(uint u1, uint v1, uint u2, uint v2)
    {
        if(texture)
            setRegion(texture.width, texture.height, u1, v1, u2, v2);
    }


    public ref float[8] getVertices(){return vertices;}
}