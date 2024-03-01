# JAX User Instructions



Testing:

```
singularity exec jax_rocm5.6.0-jax0.4.20-py3.11.0.sif /pyenv/shims/python -c 'import jax; print(jax.devices("gpu"))'
```


