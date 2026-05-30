#!/bin/bash

# Update package lists
sudo apt-get update

# Install the base LaTeX distribution and latexmk for building
sudo apt-get install -y texlive-base texlive-latex-extra latexmk

# Install the additional packages we identified as missing
sudo apt-get install -y \
    texlive-publishers \
    texlive-science \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    biber

echo "LaTeX dependencies installed successfully!"
