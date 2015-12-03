void main(void)
{
    vec4 val = texture2D(u_texture, v_tex_coord);

    if (val.a <= 0.2) {
         vec4 col = vec4(1.0, abs(1-sin(v_tex_coord.y*8 + u_time))/2, abs(1-sin(v_tex_coord.y*8 + u_time))/2, 1.0);
         gl_FragColor = col;
     } else {
         gl_FragColor = val;
    }
}