import setuptools

with open('requirements.txt', 'r',encoding='utf-8') as f:
    install_requires = f.read().splitlines()

setuptools.setup(name='LiveResponsePipeline',
      version='1.00',
      description='Defender Live Response Library Pipeline Module',
      author='Chris Smith',
      author_email='smithch@microsoft.com',
      url='',
      packages=['LiveResponsePipeline'],
      install_requires=install_requires
)
