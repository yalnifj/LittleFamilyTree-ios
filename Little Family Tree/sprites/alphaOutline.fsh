
void main(void)
{
    // The inverse of the viewport dimensions along X and Y
    vec2 u_viewportInverse = vec2(1.0 / 200.0, 1.0 / 200.0);
    
    // Color of the outline
    vec3 u_color = vec3(1.0, 0.0, 0.0);
    
    // Thickness of the outline
    float u_offset = 1.0;
    
    // Step to check for neighbors
    float u_step = 1.0 / 200;
    
    vec2 T = v_texCoord.xy;
    
    float alpha = 0.0;
    bool allin = true;
    for( float ix = -u_offset; ix < u_offset; ix += u_step )
    {
        for( float iy = -u_offset; iy < u_offset; iy += u_step )
        {
            float newAlpha = texture2D(u_texture, T + vec2(ix, iy) * u_viewportInverse).a;
            allin = allin && newAlpha > 0.5;
            if (newAlpha > 0.5 && newAlpha >= alpha)
            {
                alpha = newAlpha;
            }
        }
    }
    if (allin)
    {
        alpha = 0.0;
    }
    
    gl_FragColor = vec4(u_color,alpha);
}