/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.graphics.mesh;
import hip.hiprenderer.renderer;
import hip.hiprenderer.shader;
import hip.hiprenderer.vertex;
import hip.error.handler;
import std.traits;

class Mesh
{
    protected index_t[] indices;
    protected void[] vertices;
    ///Not yet supported
    bool isInstanced;
    private bool isBound;
    HipVertexArrayObject vao;
    Shader shader;
    this(HipVertexArrayObject vao, Shader shader)
    {
        this.vao = vao;
        this.shader = shader;
    }
    void createVertexBuffer(index_t count, HipBufferUsage usage)
    {
        this.vao.createVertexBuffer(count, usage);
    }
    void createIndexBuffer(index_t count, HipBufferUsage usage)
    {
        this.vao.createIndexBuffer(count, usage);
    }
    void sendAttributes()
    {
        this.vao.sendAttributes(shader);
    }

    void bind()
    {
        // if(!this.isBound)
        // {
            this.isBound = true;
            this.shader.bind();
            this.vao.bind();
        // }
        // else assert(false, "Erroneous call to bind.");
    }
    void unbind()
    {
        // if(this.isBound) 
        // {
            this.isBound = false;
            this.shader.unbind();
            this.vao.unbind();
        // }
        // else assert(false, "Erroneous call to unbind.");
    }

    /**
    *   Will choose between resizing buffer as needed or only updating it.
    */
    public void setIndices(index_t[] indices)
    {
        if(indices.length <  this.indices.length)
        {
            updateIndices(indices);
            return;
        }
        this.indices = indices;
        this.vao.setIndices(cast(index_t)indices.length, indices.ptr);
    }

    /**
    *   Will choose between resizing buffer as needed or only updating it.
    */
    public void setVertices(float[] vertices)
    {
        setVertices(cast(void[])vertices);
    }

    public void setVertices(void[] vertices)
    {
        if(vertices.length <= this.vertices.length)
        {
            updateVertices(vertices);
            return;
        }
        this.vertices = vertices;
        this.vao.setVertices(cast(uint)vertices.length/this.vao.stride, vertices.ptr);
    }
    /**
    *   Updates the GPU internal buffer by using the buffer sent.
    *   The offset is always multiplied by the target vertex buffer stride.
    */
    public void updateVertices(void[] vertices, int offset = 0)
    {
        this.vao.updateVertices(cast(index_t)(vertices.length/this.vao.stride), vertices.ptr, offset);
    }
    public void updateVertices(float[] vertices, int offset = 0)
    {
        updateVertices(cast(void[])vertices, offset);
    }

    public void updateIndices(index_t[] indices, int offset = 0)
    {
        this.vao.updateIndices(cast(index_t)indices.length, indices.ptr, offset);
    }
    public void setShader(Shader s){this.shader = s;}

    /**
    *   How many indices should it draw
    */
    public void draw(T)(T count, HipRendererMode mode, uint offset = 0)
    {
        static assert(isUnsigned!T, "Mesh must receive an integral type in its draw");
        ErrorHandler.assertExit(count < T.max, "Can't draw more than T.max");
        // if(isVertexArray)
        // {
            // HipRenderer.drawVertices()
        // }
        //else if(isInstanced)
        /*
        {
            HipRenderer.drawInstanced()
        }
        */
        if(!isBound) bind();
        HipRenderer.drawIndexed(mode, cast(index_t)count, offset);
    }

}
